//
//  TestWebViewController.m
//  Example
//
//  Created by wuyong on 2019/9/2.
//  Copyright © 2019 wuyong.site. All rights reserved.
//

#import "TestWebViewController.h"

// 如果需要隐藏导航栏，可以加载时显示导航栏，WebView延伸到导航栏下面，加载完成时隐藏导航栏即可
@interface TestWebViewController () <UIScrollViewDelegate>

@property (nonatomic, assign) BOOL isExtendedBottom;

@end

@implementation TestWebViewController

- (instancetype)initWithRequestUrl:(NSString *)requestUrl
{
    self = [super init];
    if (self) {
        _requestUrl = requestUrl;
    }
    return self;
}

- (NSArray *)webItems
{
    if (self.navigationItem.leftBarButtonItem) {
        return nil;
    } else {
        return @[
            [UIBarButtonItem.fw itemWithObject:FWIcon.backImage target:self action:@selector(onWebBack)],
            FWIcon.closeImage,
        ];
    }
}

- (void)onWebBack
{
    if (self.webView.canGoBack) {
        [self.webView goBack];
    } else {
        [self onWebClose];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 底部延伸时设置scrollView边距自适应，无需处理frame
    self.webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAutomatic;
    self.isExtendedBottom = [@[@YES, @NO].fw.randomObject fw].safeBool;
    if (self.isExtendedBottom) {
        self.edgesForExtendedLayout = Theme.isBarTranslucent ? UIRectEdgeAll : UIRectEdgeBottom;
    // 底部不延伸时如果显示工具栏，且hidesBottomBarWhenPushed为YES，工具栏顶部会显示空白，需处理frame
    } else {
        self.edgesForExtendedLayout = Theme.isBarTranslucent ? UIRectEdgeTop : UIRectEdgeNone;
    }
    
    [self renderToolbar];
    [self loadRequestUrl];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if (self.isExtendedBottom || !self.fw.isLoaded) return;
    
    // 顶部延伸时，不需要减顶部栏高度
    CGFloat topHeight = (self.edgesForExtendedLayout & UIRectEdgeTop) ? 0 : self.fw.topBarHeight;
    self.view.fw.height = FWScreenHeight - topHeight - self.fw.bottomBarHeight;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.toolbarHidden = YES;
}

- (void)renderWebView
{
    self.view.backgroundColor = [Theme tableColor];
    self.webView.scrollView.delegate = self;
    self.webView.scrollView.showsVerticalScrollIndicator = NO;
    self.webView.scrollView.showsHorizontalScrollIndicator = NO;
}

- (void)renderToolbar
{
    FWWeakifySelf();
    UIBarButtonItem *backItem = [UIBarButtonItem.fw itemWithObject:FWIconImage(@"ion-ios-arrow-back", 24) block:^(id  _Nonnull sender) {
        FWStrongifySelf();
        if ([self.webView canGoBack]) [self.webView goBack];
    }];
    backItem.enabled = NO;
    [self.webView.fw observeProperty:@"canGoBack" block:^(WKWebView *webView, NSDictionary * _Nonnull change) {
        FWStrongifySelf();
        backItem.enabled = webView.canGoBack;
        [self reloadToolbar:NO];
    }];
    
    UIBarButtonItem *forwardItem = [UIBarButtonItem.fw itemWithObject:FWIconImage(@"ion-ios-arrow-forward", 24) block:^(id  _Nonnull sender) {
        FWStrongifySelf();
        if ([self.webView canGoForward]) [self.webView goForward];
    }];
    forwardItem.enabled = NO;
    [self.webView.fw observeProperty:@"canGoForward" block:^(WKWebView *webView, NSDictionary * _Nonnull change) {
        FWStrongifySelf();
        forwardItem.enabled = webView.canGoForward;
        [self reloadToolbar:NO];
    }];
    
    [self.webView.fw observeProperty:@"isLoading" block:^(id  _Nonnull object, NSDictionary * _Nonnull change) {
        FWStrongifySelf();
        [self reloadToolbar:NO];
    }];
    
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spaceItem.width = 79;
    self.toolbarItems = @[flexibleItem, backItem, spaceItem, forwardItem, flexibleItem];
    
    self.navigationController.toolbar.fw_shadowImage = [UIImage.fw imageWithColor:Theme.borderColor size:CGSizeMake(self.view.bounds.size.width, 0.5)];
    self.navigationController.toolbar.fw_backgroundColor = Theme.barColor;
    self.navigationController.toolbar.fw_foregroundColor = Theme.textColor;
}

- (void)reloadToolbar:(BOOL)animated
{
    if (self.webView.canGoBack || self.webView.canGoForward) {
        if (self.fw.toolBarHidden) {
            [self.navigationController setToolbarHidden:NO animated:animated];
        }
    } else {
        if (!self.fw.toolBarHidden) {
            [self.navigationController setToolbarHidden:YES animated:animated];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!scrollView.isDragging || !scrollView.fw.canScrollVertical) return;
    
    CGPoint transition = [scrollView.panGestureRecognizer translationInView:scrollView.panGestureRecognizer.view];
    if (transition.y > 10.0f) {
        [self reloadToolbar:YES];
    } else if (transition.y < -10.0f) {
        [self.navigationController setToolbarHidden:YES animated:YES];
    }
}

- (void)shareRequestUrl
{
    [UIApplication.fw openActivityItems:@[FWSafeURL(self.requestUrl)] excludedTypes:nil];
}

- (void)loadRequestUrl
{
    [self.fw hideEmptyView];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.requestUrl]];
    urlRequest.timeoutInterval = 30;
    [urlRequest setValue:@"test" forHTTPHeaderField:@"Test-Token"];
    self.webRequest = urlRequest;
}

- (void)webViewFinishLoad
{
    if (self.fw.isLoaded) return;
    self.fw.isLoaded = YES;
    
    [self.fw setRightBarItem:FWIcon.actionImage target:self action:@selector(shareRequestUrl)];
}

- (void)webViewFailLoad:(NSError *)error
{
    if (self.fw.isLoaded) return;
    
    [self.fw setRightBarItem:FWIcon.refreshImage target:self action:@selector(loadRequestUrl)];
    
    FWWeakifySelf();
    [self.fw showEmptyViewWithText:error.localizedDescription detail:nil image:nil action:@"点击重试" block:^(id  _Nonnull sender) {
        FWStrongifySelf();
        [self loadRequestUrl];
    }];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    if ([self respondsToSelector:@selector(webViewShouldLoad:)] &&
        ![self webViewShouldLoad:navigationAction]) {
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    if ([UIApplication.fw isSystemURL:navigationAction.request.URL]) {
        [UIApplication.fw openURL:navigationAction.request.URL];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    if ([navigationAction.request.URL.scheme isEqualToString:@"app"]) {
        [FWRouter openURL:navigationAction.request.URL.absoluteString];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    if ([navigationAction.request.URL.scheme isEqualToString:@"https"]) {
        [UIApplication.fw openUniversalLinks:navigationAction.request.URL completionHandler:^(BOOL success) {
            if (success) {
                decisionHandler(WKNavigationActionPolicyCancel);
            } else {
                decisionHandler(WKNavigationActionPolicyAllow);
            }
        }];
        return;
    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
}

@end
