/**
 @header     FWToastPluginImpl.m
 @indexgroup FWApplication
      FWToastPluginImpl
 @author     wuyong
 @copyright  Copyright © 2018年 wuyong.site. All rights reserved.
 @updated    2018/9/22
 */

#import "FWToastPluginImpl.h"

#pragma mark - FWToastPluginImpl

@implementation FWToastPluginImpl

+ (FWToastPluginImpl *)sharedInstance
{
    static FWToastPluginImpl *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[FWToastPluginImpl alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _fadeAnimated = YES;
        _delayTime = 2.0;
    }
    return self;
}

- (void)showLoadingWithAttributedText:(NSAttributedString *)attributedText inView:(UIView *)view
{
    NSAttributedString *loadingText = attributedText;
    if (!loadingText && self.defaultLoadingText) {
        loadingText = self.defaultLoadingText();
    }
    
    FWToastView *toastView = [view viewWithTag:2011];
    if (toastView) {
        [toastView invalidateTimer];
        [view bringSubviewToFront:toastView];
        toastView.attributedTitle = loadingText;
        return;
    }
    
    toastView = [[FWToastView alloc] initWithType:FWToastViewTypeIndicator];
    toastView.tag = 2011;
    toastView.attributedTitle = loadingText;
    [view addSubview:toastView];
    [toastView fw_pinEdgesToSuperviewWithInsets:view.fw.toastInsets];
    
    if (self.customBlock) {
        self.customBlock(toastView);
    }
    [toastView showAnimated:self.fadeAnimated];
}

- (void)hideLoading:(UIView *)view
{
    FWToastView *toastView = [view viewWithTag:2011];
    if (toastView) [toastView hide];
}

- (void)showProgressWithAttributedText:(NSAttributedString *)attributedText progress:(CGFloat)progress inView:(UIView *)view
{
    NSAttributedString *progressText = attributedText;
    if (!progressText && self.defaultProgressText) {
        progressText = self.defaultProgressText();
    }
    
    FWToastView *toastView = [view viewWithTag:2012];
    if (toastView) {
        [toastView invalidateTimer];
        [view bringSubviewToFront:toastView];
        toastView.attributedTitle = progressText;
        toastView.progress = progress;
        return;
    }
    
    toastView = [[FWToastView alloc] initWithType:FWToastViewTypeProgress];
    toastView.tag = 2012;
    toastView.attributedTitle = progressText;
    toastView.progress = progress;
    [view addSubview:toastView];
    [toastView fw_pinEdgesToSuperviewWithInsets:view.fw.toastInsets];
    
    if (self.customBlock) {
        self.customBlock(toastView);
    }
    [toastView showAnimated:self.fadeAnimated];
}

- (void)hideProgress:(UIView *)view
{
    FWToastView *toastView = [view viewWithTag:2012];
    if (toastView) [toastView hide];
}

- (void)showMessageWithAttributedText:(NSAttributedString *)attributedText style:(FWToastStyle)style autoHide:(BOOL)autoHide completion:(void (^)(void))completion inView:(UIView *)view
{
    NSAttributedString *messageText = attributedText;
    if (!messageText && self.defaultMessageText) {
        messageText = self.defaultMessageText(style);
    }
    if (messageText.length < 1) return;
    
    FWToastView *toastView = [view viewWithTag:2013];
    BOOL fadeAnimated = self.fadeAnimated && !toastView;
    if (toastView) [toastView hide];
    
    toastView = [[FWToastView alloc] initWithType:FWToastViewTypeText];
    toastView.tag = 2013;
    toastView.userInteractionEnabled = completion ? YES : NO;
    toastView.attributedTitle = messageText;
    [view addSubview:toastView];
    [toastView fw_pinEdgesToSuperviewWithInsets:view.fw.toastInsets];
    
    if (self.customBlock) {
        self.customBlock(toastView);
    }
    [toastView showAnimated:fadeAnimated];
    
    if (autoHide) {
        [toastView hideAfterDelay:self.delayTime completion:completion];
    }
}

- (void)hideMessage:(UIView *)view
{
    FWToastView *toastView = [view viewWithTag:2013];
    if (toastView) [toastView hide];
}

@end
