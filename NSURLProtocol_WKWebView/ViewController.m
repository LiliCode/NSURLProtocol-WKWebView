//
//  ViewController.m
//  NSURLProtocol_WKWebView
//
//  Created by 唯赢 on 2018/11/23.
//  Copyright © 2018 李立. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import "WKWebView+NSURLProtocol.h"

@interface ViewController ()<WKNavigationDelegate>
@property (strong, nonatomic) WKWebView *wkWebView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //创建WKWebview
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    self.wkWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) configuration:config];
    self.wkWebView.navigationDelegate = self;
    [self.wkWebView supportURLProtocol];
    [self.wkWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.baidu.com"]]];
    [self.view addSubview:self.wkWebView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.wkWebView.frame = self.view.bounds;
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [webView evaluateJavaScript:@"document.title" completionHandler:^(id _Nullable returnValue, NSError * _Nullable error) {
        if (!error) {
            self.title = returnValue;
        }
    }];
}

- (IBAction)backAction:(UIBarButtonItem *)sender {
    if ([self.wkWebView canGoBack]) {
        [self.wkWebView goBack];
    }
}

- (IBAction)forwardAction:(UIBarButtonItem *)sender {
    if ([self.wkWebView canGoForward]) {
        [self.wkWebView goForward];
    }
}

@end
