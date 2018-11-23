使用说明
======
>WKWebView支持NSURLProtocol协议，可以做请求重定向，防止DNS劫持，支持WebP格式图片，缓存等...

使用方法
------
1. 将 WKWebView+NSURLProtocol 分类导入工程中
2. 在使用到 WKWebView 的地方调用 supportURLProtocol 方法

```objc
self.wkWebView = ...
[self.wkWebView supportURLProtocol];
```
3. 创建一个继承自 NSURLProtocol 类的Protocol协议对象(比如：WKWebViewURLProtocol)，并实现其中的方法（参考链接:https://www.jianshu.com/p/7c89b8c5482a）。
4. 注册自定义 NSURLProtocol 
```objc
[NSURLProtocol registerClass:[WKWebViewURLProtocol class]];
```
支持WebP格式图片
-----
>使用 SDWebImage 加载WebP格式图片，需要导入WebP分支
```Ruby
pod 'SDWebImage/WebP'
```
>在 NSURLProtocol 的重定向方法中判断图片中是否有 webp 字样，然后使用 SDWebImage 中的方法加载WebP图片。
参考链接:https://www.jianshu.com/p/e2459c9e9340

防止DNS劫持
-----
> 使用阿里云的 AlicloudHttpDNS 可以实现此功能

许可证
-----
MIT-license
