/**
 @header     FWCollectionViewController.m
 @indexgroup FWApplication
      FWCollectionViewController
 @author     wuyong
 @copyright  Copyright © 2019 wuyong.site. All rights reserved.
 @updated    2019/8/28
 */

#import "FWCollectionViewController.h"
#import <objc/runtime.h>
@import FWFramework;

#pragma mark - FWViewControllerManager+FWCollectionViewController

@implementation FWViewControllerManager (FWCollectionViewController)

+ (void)load
{
    FWViewControllerIntercepter *intercepter = [[FWViewControllerIntercepter alloc] init];
    intercepter.loadViewIntercepter = @selector(collectionViewControllerLoadView:);
    intercepter.forwardSelectors = @{
        @"collectionView" : @"fw_innerCollectionView",
        @"collectionData" : @"fw_innerCollectionData",
        @"renderCollectionViewLayout" : @"fw_innerRenderCollectionViewLayout",
        @"renderCollectionLayout" : @"fw_innerRenderCollectionLayout",
    };
    [[FWViewControllerManager sharedInstance] registerProtocol:@protocol(FWCollectionViewController) withIntercepter:intercepter];
}

- (void)collectionViewControllerLoadView:(UIViewController<FWCollectionViewController> *)viewController
{
    UICollectionView *collectionView = [viewController collectionView];
    collectionView.dataSource = viewController;
    collectionView.delegate = viewController;
    [viewController.view addSubview:collectionView];
    
    if (self.hookCollectionViewController) {
        self.hookCollectionViewController(viewController);
    }
    
    if ([viewController respondsToSelector:@selector(renderCollectionView)]) {
        [viewController renderCollectionView];
    }
    
    [viewController renderCollectionLayout];
    [collectionView setNeedsLayout];
    [collectionView layoutIfNeeded];
}

@end

#pragma mark - UIViewController+FWCollectionViewController

@interface UIViewController (FWCollectionViewController)

@end

@implementation UIViewController (FWCollectionViewController)

- (UICollectionView *)fw_innerCollectionView
{
    UICollectionView *collectionView = objc_getAssociatedObject(self, _cmd);
    if (!collectionView) {
        UICollectionViewLayout *viewLayout = [(id<FWCollectionViewController>)self renderCollectionViewLayout];
        collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:viewLayout];
        collectionView.showsVerticalScrollIndicator = NO;
        collectionView.showsHorizontalScrollIndicator = NO;
        objc_setAssociatedObject(self, _cmd, collectionView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return collectionView;
}

- (NSMutableArray *)fw_innerCollectionData
{
    NSMutableArray *collectionData = objc_getAssociatedObject(self, _cmd);
    if (!collectionData) {
        collectionData = [[NSMutableArray alloc] init];
        objc_setAssociatedObject(self, _cmd, collectionData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return collectionData;
}

- (UICollectionViewLayout *)fw_innerRenderCollectionViewLayout
{
    UICollectionViewFlowLayout *viewLayout = [[UICollectionViewFlowLayout alloc] init];
    viewLayout.minimumLineSpacing = 0;
    viewLayout.minimumInteritemSpacing = 0;
    return viewLayout;
}

- (void)fw_innerRenderCollectionLayout
{
    UICollectionView *collectionView = [(id<FWCollectionViewController>)self collectionView];
    [collectionView fw_pinEdgesToSuperview];
}

@end
