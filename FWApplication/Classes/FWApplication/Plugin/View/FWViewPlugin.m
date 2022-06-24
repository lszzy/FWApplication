/**
 @header     FWViewPlugin.m
 @indexgroup FWApplication
      FWViewPlugin
 @author     wuyong
 @copyright  Copyright © 2018年 wuyong.site. All rights reserved.
 @updated    2018/9/22
 */

#import "FWViewPlugin.h"
#import "FWViewPluginImpl.h"
#import <objc/runtime.h>

#pragma mark - UIView+FWViewPlugin

@implementation UIView (FWViewPlugin)

- (id<FWViewPlugin>)fw_viewPlugin
{
    id<FWViewPlugin> viewPlugin = objc_getAssociatedObject(self, @selector(fw_viewPlugin));
    if (!viewPlugin) viewPlugin = [FWPluginManager loadPlugin:@protocol(FWViewPlugin)];
    if (!viewPlugin) viewPlugin = FWViewPluginImpl.sharedInstance;
    return viewPlugin;
}

- (void)setFw_viewPlugin:(id<FWViewPlugin>)viewPlugin
{
    objc_setAssociatedObject(self, @selector(fw_viewPlugin), viewPlugin, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView<FWProgressViewPlugin> *)fw_progressViewWithStyle:(FWProgressViewStyle)style
{
    id<FWViewPlugin> plugin = self.fw_viewPlugin;
    if (!plugin || ![plugin respondsToSelector:@selector(progressViewWithStyle:)]) {
        plugin = FWViewPluginImpl.sharedInstance;
    }
    return [plugin progressViewWithStyle:style];
}

- (UIView<FWIndicatorViewPlugin> *)fw_indicatorViewWithStyle:(FWIndicatorViewStyle)style
{
    id<FWViewPlugin> plugin = self.fw_viewPlugin;
    if (!plugin || ![plugin respondsToSelector:@selector(indicatorViewWithStyle:)]) {
        plugin = FWViewPluginImpl.sharedInstance;
    }
    return [plugin indicatorViewWithStyle:style];
}

+ (UIView<FWProgressViewPlugin> *)fw_progressViewWithStyle:(FWProgressViewStyle)style
{
    id<FWViewPlugin> plugin = [FWPluginManager loadPlugin:@protocol(FWViewPlugin)];
    if (!plugin || ![plugin respondsToSelector:@selector(progressViewWithStyle:)]) {
        plugin = FWViewPluginImpl.sharedInstance;
    }
    return [plugin progressViewWithStyle:style];
}

+ (UIView<FWIndicatorViewPlugin> *)fw_indicatorViewWithStyle:(FWIndicatorViewStyle)style
{
    id<FWViewPlugin> plugin = [FWPluginManager loadPlugin:@protocol(FWViewPlugin)];
    if (!plugin || ![plugin respondsToSelector:@selector(indicatorViewWithStyle:)]) {
        plugin = FWViewPluginImpl.sharedInstance;
    }
    return [plugin indicatorViewWithStyle:style];
}

@end
