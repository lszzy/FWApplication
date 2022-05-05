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

#pragma mark - FWViewWrapper+FWViewPlugin

@implementation FWViewWrapper (FWViewPlugin)

- (id<FWViewPlugin>)viewPlugin
{
    id<FWViewPlugin> viewPlugin = objc_getAssociatedObject(self.base, @selector(viewPlugin));
    if (!viewPlugin) viewPlugin = [FWPluginManager loadPlugin:@protocol(FWViewPlugin)];
    if (!viewPlugin) viewPlugin = FWViewPluginImpl.sharedInstance;
    return viewPlugin;
}

- (void)setViewPlugin:(id<FWViewPlugin>)viewPlugin
{
    objc_setAssociatedObject(self.base, @selector(viewPlugin), viewPlugin, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView<FWProgressViewPlugin> *)progressViewWithStyle:(FWProgressViewStyle)style
{
    id<FWViewPlugin> plugin = self.viewPlugin;
    if (!plugin || ![plugin respondsToSelector:@selector(progressViewWithStyle:)]) {
        plugin = FWViewPluginImpl.sharedInstance;
    }
    return [plugin progressViewWithStyle:style];
}

- (UIView<FWIndicatorViewPlugin> *)indicatorViewWithStyle:(FWIndicatorViewStyle)style
{
    id<FWViewPlugin> plugin = self.viewPlugin;
    if (!plugin || ![plugin respondsToSelector:@selector(indicatorViewWithStyle:)]) {
        plugin = FWViewPluginImpl.sharedInstance;
    }
    return [plugin indicatorViewWithStyle:style];
}

@end

@implementation FWViewClassWrapper (FWViewPlugin)

- (UIView<FWProgressViewPlugin> *)progressViewWithStyle:(FWProgressViewStyle)style
{
    id<FWViewPlugin> plugin = [FWPluginManager loadPlugin:@protocol(FWViewPlugin)];
    if (!plugin || ![plugin respondsToSelector:@selector(progressViewWithStyle:)]) {
        plugin = FWViewPluginImpl.sharedInstance;
    }
    return [plugin progressViewWithStyle:style];
}

- (UIView<FWIndicatorViewPlugin> *)indicatorViewWithStyle:(FWIndicatorViewStyle)style
{
    id<FWViewPlugin> plugin = [FWPluginManager loadPlugin:@protocol(FWViewPlugin)];
    if (!plugin || ![plugin respondsToSelector:@selector(indicatorViewWithStyle:)]) {
        plugin = FWViewPluginImpl.sharedInstance;
    }
    return [plugin indicatorViewWithStyle:style];
}

@end
