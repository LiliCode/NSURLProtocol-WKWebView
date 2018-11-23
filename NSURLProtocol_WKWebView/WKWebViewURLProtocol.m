//
//  WKWebViewURLProtocol.m
//  NSURLProtocol_WKWebView
//
//  Created by 唯赢 on 2018/11/23.
//  Copyright © 2018 李立. All rights reserved.
//

#import "WKWebViewURLProtocol.h"

static NSString * const URLProtocolHandledKey = @"URLProtocolHandledKey";

@interface WKWebViewURLProtocol ()<NSURLSessionDelegate>
@property (nonatomic, strong) NSURLSessionDataTask *task;

@end

@implementation WKWebViewURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    if ([request.URL.scheme caseInsensitiveCompare:@"http"] == NSOrderedSame ||
        [request.URL.scheme caseInsensitiveCompare:@"https"] == NSOrderedSame) {
        if ([NSURLProtocol propertyForKey:URLProtocolHandledKey inRequest:request]) {
            return NO;
        }

        return YES;
    }

    return NO;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    
    // 测试代码
    // 替换大部分图片
    if ([request.URL.absoluteString hasSuffix:@".jpg"] ||
        [request.URL.absoluteString containsString:@"JPG"] ||
        [request.URL.absoluteString containsString:@"JPEG"]) {
        
        NSMutableURLRequest *mRequest = [request mutableCopy];
        mRequest.URL = [NSURL URLWithString:@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1542968462973&di=879a5f6b3c59ffddccb2d7e064e9b422&imgtype=0&src=http%3A%2F%2Fimg.leikeji.com%2Fresource%2Fimg%2Ff5290ea6de864ae0b9486626f52f3415.jpeg%4033-21-1480-887a"];
        return [mRequest copy];
    }
    
    return request;
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b {
    return [super requestIsCacheEquivalent:a toRequest:b];
}

- (void)startLoading {
    // 重定向请求
    NSMutableURLRequest *mutableReqeust = [[self request] mutableCopy];
    //标识该request已经处理过了，防止无限循环
    [NSURLProtocol setProperty:@YES forKey:URLProtocolHandledKey inRequest:mutableReqeust];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    self.task = [session dataTaskWithRequest:mutableReqeust];
    
    [self.task resume];
}

- (void)stopLoading {
    [self.task cancel];
}

#pragma mark - NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(nonnull NSURLSessionDataTask *)dataTask didReceiveResponse:(nonnull NSURLResponse *)response completionHandler:(nonnull void (^)(NSURLSessionResponseDisposition))completionHandler {
    // 将收到的数据传递给发送请求的类
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
    completionHandler(NSURLSessionResponseAllow);   // 允许响应
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [[self client] URLProtocol:self didLoadData:data];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    // 请求完成,成功或者失败的处理
    if (!error) {
        //成功
        [self.client URLProtocolDidFinishLoading:self];
    } else {
        //失败
        [self.client URLProtocol:self didFailWithError:error];
    }
}

- (BOOL)evaluateServerTrust:(SecTrustRef)serverTrust forDomain:(NSString *)domain {
    /*
     * 创建证书校验策略
     */
    NSMutableArray *policies = [NSMutableArray array];
    if (domain) {
        [policies addObject:(__bridge_transfer id) SecPolicyCreateSSL(true, (__bridge CFStringRef) domain)];
    } else {
        [policies addObject:(__bridge_transfer id) SecPolicyCreateBasicX509()];
    }
    /*
     * 绑定校验策略到服务端的证书上
     */
    SecTrustSetPolicies(serverTrust, (__bridge CFArrayRef) policies);
    /*
     * 评估当前serverTrust是否可信任，
     * 官方建议在result = kSecTrustResultUnspecified 或 kSecTrustResultProceed
     * 的情况下serverTrust可以被验证通过，https://developer.apple.com/library/ios/technotes/tn2232/_index.html
     * 关于SecTrustResultType的详细信息请参考SecTrust.h
     */
    SecTrustResultType result;
    SecTrustEvaluate(serverTrust, &result);
    if (result == kSecTrustResultUnspecified || result == kSecTrustResultProceed) {
        return YES;
    }
    return NO;
}


- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * __nullable credential))completionHandler {
    if (!challenge) {
        return;
    }
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    NSURLCredential *credential = nil;
    
    /**
     * 获取原始域名信息。URL里面的host在使用“IP直连”的情况下被设置成了IP，此处从HTTP Header中获取真实域名
     */
    NSString* host = [[self.request allHTTPHeaderFields] objectForKey:@"host"];
    if (!host) {
        host = self.request.URL.host;
    }
    
    /**
     * 判断challenge的身份验证方法是否是NSURLAuthenticationMethodServerTrust（HTTPS模式下会进行该身份验证流程），
     * 在没有配置身份验证方法的情况下进行默认的网络请求流程。
     */
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        if ([self evaluateServerTrust:challenge.protectionSpace.serverTrust forDomain:host]) {
            disposition = NSURLSessionAuthChallengeUseCredential;
            credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        } else {
            disposition = NSURLSessionAuthChallengePerformDefaultHandling;
        }
    } else {
        disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    }
    // 对于其他的challenges直接使用默认的验证方案
    completionHandler(disposition,credential);
}



@end
