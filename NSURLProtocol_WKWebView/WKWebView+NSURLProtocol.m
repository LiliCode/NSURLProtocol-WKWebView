//
//  WKWebView+NSURLProtocol.m
//  NSURLProtocol_WKWebView
//
//  Created by 唯赢 on 2018/11/23.
//  Copyright © 2018 李立. All rights reserved.
//

#import "WKWebView+NSURLProtocol.h"

@implementation WKWebView (NSURLProtocol)

- (void)supportURLProtocol {
    // 参考资料：https://www.jianshu.com/p/8f5e1082f5e0
    // 注册scheme
    Class cls = NSClassFromString(@"WKBrowsingContextController");
    SEL selector = NSSelectorFromString(@"registerSchemeForCustomProtocol:");
    if ([cls respondsToSelector:selector]) {
        // 通过http和https的请求，同理可通过其他的Scheme 但是要满足ULR Loading System
        // 以下方法类似：performSelector:withObject:
        IMP (*func)(id, SEL, id) = (void *)[cls methodForSelector:selector];
        func(cls, selector, @"http");       // 注册http
        func(cls, selector, @"https");      // 注册https
    }
}

@end
