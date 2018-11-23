//
//  WKWebView+NSURLProtocol.h
//  NSURLProtocol_WKWebView
//
//  Created by 唯赢 on 2018/11/23.
//  Copyright © 2018 李立. All rights reserved.
//

#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WKWebView (NSURLProtocol)

/**
 支持NSURLProtocol协议
 */
- (void)supportURLProtocol;

@end

NS_ASSUME_NONNULL_END
