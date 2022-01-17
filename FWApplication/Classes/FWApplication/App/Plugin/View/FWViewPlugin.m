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
@import FWFramework;

#pragma mark - UIView+FWViewPlugin

@implementation UIView (FWViewPlugin)

- (id<FWViewPlugin>)fwViewPlugin
{
    id<FWViewPlugin> viewPlugin = objc_getAssociatedObject(self, @selector(fwViewPlugin));
    if (!viewPlugin) viewPlugin = [FWPluginManager loadPlugin:@protocol(FWViewPlugin)];
    if (!viewPlugin) viewPlugin = FWViewPluginImpl.sharedInstance;
    return viewPlugin;
}

- (void)setFwViewPlugin:(id<FWViewPlugin>)fwViewPlugin
{
    objc_setAssociatedObject(self, @selector(fwViewPlugin), fwViewPlugin, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView<FWProgressViewPlugin> *)fwProgressViewWithStyle:(FWProgressViewStyle)style
{
    id<FWViewPlugin> plugin = self.fwViewPlugin;
    if (!plugin || ![plugin respondsToSelector:@selector(fwProgressViewWithStyle:)]) {
        plugin = FWViewPluginImpl.sharedInstance;
    }
    return [plugin progressViewWithStyle:style];
}

- (UIView<FWIndicatorViewPlugin> *)fwIndicatorViewWithStyle:(FWIndicatorViewStyle)style
{
    id<FWViewPlugin> plugin = self.fwViewPlugin;
    if (!plugin || ![plugin respondsToSelector:@selector(fwIndicatorViewWithStyle:)]) {
        plugin = FWViewPluginImpl.sharedInstance;
    }
    return [plugin indicatorViewWithStyle:style];
}

+ (UIView<FWProgressViewPlugin> *)fwProgressViewWithStyle:(FWProgressViewStyle)style
{
    id<FWViewPlugin> plugin = [FWPluginManager loadPlugin:@protocol(FWViewPlugin)];
    if (!plugin || ![plugin respondsToSelector:@selector(fwProgressViewWithStyle:)]) {
        plugin = FWViewPluginImpl.sharedInstance;
    }
    return [plugin progressViewWithStyle:style];
}

+ (UIView<FWIndicatorViewPlugin> *)fwIndicatorViewWithStyle:(FWIndicatorViewStyle)style
{
    id<FWViewPlugin> plugin = [FWPluginManager loadPlugin:@protocol(FWViewPlugin)];
    if (!plugin || ![plugin respondsToSelector:@selector(fwIndicatorViewWithStyle:)]) {
        plugin = FWViewPluginImpl.sharedInstance;
    }
    return [plugin indicatorViewWithStyle:style];
}

@end
