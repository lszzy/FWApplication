//
//  FWBadgeView.m
//  FWApplication
//
//  Created by wuyong on 2017/4/10.
//  Copyright © 2018年 wuyong.site. All rights reserved.
//

#import "FWBadgeView.h"
#import <objc/runtime.h>

#pragma mark - FWBadgeView

@implementation FWBadgeView

- (instancetype)initWithBadgeStyle:(FWBadgeStyle)badgeStyle
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        // 根据样式处理
        _badgeStyle = badgeStyle;
        switch (badgeStyle) {
            case FWBadgeStyleSmall: {
                [self setupWithBadgeHeight:18.f badgeOffset:CGPointMake(7.f, 7.f) textInset:5.f fontSize:12.f];
                break;
            }
            case FWBadgeStyleBig: {
                [self setupWithBadgeHeight:24.f badgeOffset:CGPointMake(9.f, 9.f) textInset:6.f fontSize:14.f];
                break;
            }
            case FWBadgeStyleDot:
            default: {
                CGFloat badgeHeight = 10.f;
                _badgeOffset = CGPointMake(3.f, 3.f);
                
                self.userInteractionEnabled = NO;
                self.backgroundColor = [UIColor redColor];
                self.layer.cornerRadius = badgeHeight / 2.0;
                [self.fw setDimensionsToSize:CGSizeMake(badgeHeight, badgeHeight)];
                break;
            }
        }
    }
    return self;
}

- (instancetype)initWithBadgeHeight:(CGFloat)badgeHeight badgeOffset:(CGPoint)badgeOffset textInset:(CGFloat)textInset fontSize:(CGFloat)fontSize
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        [self setupWithBadgeHeight:badgeHeight badgeOffset:badgeOffset textInset:textInset fontSize:fontSize];
    }
    return self;
}

- (void)setupWithBadgeHeight:(CGFloat)badgeHeight badgeOffset:(CGPoint)badgeOffset textInset:(CGFloat)textInset fontSize:(CGFloat)fontSize
{
    _badgeOffset = badgeOffset;
    
    self.userInteractionEnabled = NO;
    self.backgroundColor = [UIColor redColor];
    self.layer.cornerRadius = badgeHeight / 2.0;
    [self.fw setDimension:NSLayoutAttributeHeight toSize:badgeHeight];
    [self.fw setDimension:NSLayoutAttributeWidth toSize:badgeHeight relation:NSLayoutRelationGreaterThanOrEqual];
    
    _badgeLabel = [[UILabel alloc] init];
    _badgeLabel.textColor = [UIColor whiteColor];
    _badgeLabel.font = [UIFont systemFontOfSize:fontSize];
    _badgeLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_badgeLabel];
    [_badgeLabel.fw alignCenterToSuperview];
    [_badgeLabel.fw pinEdgeToSuperview:NSLayoutAttributeRight withInset:textInset relation:NSLayoutRelationGreaterThanOrEqual];
    [_badgeLabel.fw pinEdgeToSuperview:NSLayoutAttributeLeft withInset:textInset relation:NSLayoutRelationGreaterThanOrEqual];
}

@end

#pragma mark - FWViewWrapper+FWBadge

@implementation FWViewWrapper (FWBadge)

- (void)showBadgeView:(FWBadgeView *)badgeView badgeValue:(NSString *)badgeValue
{
    [self hideBadgeView];
    
    badgeView.badgeLabel.text = badgeValue;
    badgeView.tag = 2041;
    [self.base addSubview:badgeView];
    [self.base bringSubviewToFront:badgeView];
    
    // 默认偏移
    [badgeView.fw pinEdgeToSuperview:NSLayoutAttributeTop withInset:-badgeView.badgeOffset.y];
    [badgeView.fw pinEdgeToSuperview:NSLayoutAttributeRight withInset:-badgeView.badgeOffset.x];
}

- (void)hideBadgeView
{
    UIView *badgeView = [self.base viewWithTag:2041];
    if (badgeView) {
        [badgeView removeFromSuperview];
    }
}

@end

#pragma mark - FWBarItemWrapper+FWBadge

@implementation FWBarItemWrapper (FWBadge)

- (UIView *)view
{
    if ([self.base isKindOfClass:[UIBarButtonItem class]]) {
        if (((UIBarButtonItem *)self.base).customView != nil) {
            return ((UIBarButtonItem *)self.base).customView;
        }
    }
    
    if ([self.base respondsToSelector:@selector(view)]) {
        return [self invokeGetter:@"view"];
    }
    return nil;
}

- (void (^)(__kindof UIBarItem *, UIView *))viewLoadedBlock
{
    return objc_getAssociatedObject(self.base, @selector(viewLoadedBlock));
}

- (void)setViewLoadedBlock:(void (^)(__kindof UIBarItem *, UIView *))block
{
    objc_setAssociatedObject(self.base, @selector(viewLoadedBlock), block, OBJC_ASSOCIATION_COPY_NONATOMIC);

    UIView *view = [self view];
    if (view) {
        block(self.base, view);
    } else {
        [self observeProperty:@"view" block:^(UIBarItem *object, NSDictionary *change) {
            if (![change objectForKey:NSKeyValueChangeNewKey]) return;
            [object.fw unobserveProperty:@"view"];
            
            UIView *view = [object.fw view];
            if (view && object.fw.viewLoadedBlock) {
                object.fw.viewLoadedBlock(object, view);
            }
        }];
    }
}

@end

#pragma mark - FWBarButtonItemWrapper+FWBadge

@implementation FWBarButtonItemWrapper (FWBadge)

- (void)showBadgeView:(FWBadgeView *)badgeView badgeValue:(NSString *)badgeValue
{
    [self hideBadgeView];
    
    // 查找内部视图，由于view只有显示到页面后才存在，所以使用回调存在后才添加
    self.viewLoadedBlock = ^(UIBarButtonItem *item, UIView *view) {
        badgeView.badgeLabel.text = badgeValue;
        badgeView.tag = 2041;
        [view addSubview:badgeView];
        [view bringSubviewToFront:badgeView];
        
        // 自定义视图时默认偏移，否则固定偏移
        [badgeView.fw pinEdgeToSuperview:NSLayoutAttributeTop withInset:badgeView.badgeStyle == 0 ? -badgeView.badgeOffset.y : 0];
        [badgeView.fw pinEdgeToSuperview:NSLayoutAttributeRight withInset:badgeView.badgeStyle == 0 ? -badgeView.badgeOffset.x : 0];
    };
}

- (void)hideBadgeView
{
    UIView *superview = [self view];
    if (superview) {
        UIView *badgeView = [superview viewWithTag:2041];
        if (badgeView) {
            [badgeView removeFromSuperview];
        }
    }
}

@end

#pragma mark - FWTabBarItemWrapper+FWBadege

@implementation FWTabBarItemWrapper (FWBadge)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        FWSwizzleMethod(objc_getClass("UITabBarButton"), @selector(layoutSubviews), nil, FWSwizzleType(UIView *), FWSwizzleReturn(void), FWSwizzleArgs(), FWSwizzleCode({
            FWSwizzleOriginal();
            
            // 解决因为层级关系变化导致的badgeView被遮挡问题
            for (UIView *subview in selfObject.subviews) {
                if ([subview isKindOfClass:[FWBadgeView class]]) {
                    FWBadgeView *badgeView = (FWBadgeView *)subview;
                    [selfObject bringSubviewToFront:badgeView];
                    
                    // 解决iOS13因为磨砂层切换导致的badgeView位置不对问题
                    if (@available(iOS 13.0, *)) {
                        UIView *imageView = [FWTabBarItemWrapper imageView:selfObject];
                        if (imageView) [badgeView.fw pinEdge:NSLayoutAttributeLeft toEdge:NSLayoutAttributeRight ofView:imageView withOffset:badgeView.badgeStyle == 0 ? -badgeView.badgeOffset.x : -badgeView.badgeOffset.x];
                    }
                    break;
                }
            }
        }));
    });
}

+ (UIImageView *)imageView:(UIView *)tabBarButton
{
    if (!tabBarButton) return nil;
    
    UIView *superview = tabBarButton;
    if (@available(iOS 13.0, *)) {
        // iOS 13 下如果 tabBar 是磨砂的，则每个 button 内部都会有一个磨砂，而磨砂再包裹了 imageView、label 等 subview，但某些时机后系统又会把 imageView、label 挪出来放到 button 上，所以这里做个保护
        if ([tabBarButton.subviews.firstObject isKindOfClass:[UIVisualEffectView class]] && ((UIVisualEffectView *)tabBarButton.subviews.firstObject).contentView.subviews.count) {
            superview = ((UIVisualEffectView *)tabBarButton.subviews.firstObject).contentView;
        }
    }
    
    for (UIView *subview in superview.subviews) {
        // iOS10及以后，imageView都是用UITabBarSwappableImageView实现的，所以遇到这个class就直接拿
        if ([NSStringFromClass([subview class]) isEqualToString:@"UITabBarSwappableImageView"]) {
            return (UIImageView *)subview;
        }
    }
    return nil;
}

- (UIImageView *)imageView
{
    UIView *tabBarButton = [self view];
    return [FWTabBarItemWrapper imageView:tabBarButton];
}

- (void)showBadgeView:(FWBadgeView *)badgeView badgeValue:(NSString *)badgeValue
{
    [self hideBadgeView];
    
    // 查找内部视图，由于view只有显示到页面后才存在，所以使用回调存在后才添加
    self.viewLoadedBlock = ^(UITabBarItem *item, UIView *view) {
        UIView *imageView = item.fw.imageView;
        if (!imageView) return;
        
        badgeView.badgeLabel.text = badgeValue;
        badgeView.tag = 2041;
        [view addSubview:badgeView];
        [view bringSubviewToFront:badgeView];
        [badgeView.fw pinEdgeToSuperview:NSLayoutAttributeTop withInset:badgeView.badgeStyle == 0 ? -badgeView.badgeOffset.y : 2.f];
        [badgeView.fw pinEdge:NSLayoutAttributeLeft toEdge:NSLayoutAttributeRight ofView:imageView withOffset:badgeView.badgeStyle == 0 ? -badgeView.badgeOffset.x : -badgeView.badgeOffset.x];
    };
}

- (void)hideBadgeView
{
    UIView *superview = [self view];
    if (superview) {
        UIView *badgeView = [superview viewWithTag:2041];
        if (badgeView) {
            [badgeView removeFromSuperview];
        }
    }
}

@end
