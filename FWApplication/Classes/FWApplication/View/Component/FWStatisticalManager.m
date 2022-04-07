/**
 @header     FWStatisticalManager.m
 @indexgroup FWApplication
      FWStatisticalManager
 @author     wuyong
 @copyright  Copyright © 2020 wuyong.site. All rights reserved.
 @updated    2020/2/4
 */

#import "FWStatisticalManager.h"
#import "UITableView+FWApplication.h"
#import "UICollectionView+FWApplication.h"
#import <objc/runtime.h>
@import FWFramework;

#pragma mark - FWStatistical

NSString *const FWStatisticalEventTriggeredNotification = @"FWStatisticalEventTriggeredNotification";

@interface FWStatisticalManager ()

@property (nonatomic, strong) NSMutableDictionary *eventHandlers;

@end

@implementation FWStatisticalManager

+ (instancetype)sharedInstance
{
    static FWStatisticalManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[FWStatisticalManager alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _runLoopMode = NSDefaultRunLoopMode;
        _eventHandlers = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)registerEvent:(NSString *)name withHandler:(FWStatisticalBlock)handler
{
    [self.eventHandlers setObject:handler forKey:name];
}

- (void)handleEvent:(FWStatisticalObject *)object
{
    FWStatisticalBlock eventHandler = [self.eventHandlers objectForKey:object.name];
    if (eventHandler) {
        eventHandler(object);
    }
    if (self.globalHandler) {
        self.globalHandler(object);
    }
    if (self.notificationEnabled) {
        [[NSNotificationCenter defaultCenter] postNotificationName:FWStatisticalEventTriggeredNotification object:object userInfo:object.userInfo];
    }
}

@end

@interface FWStatisticalObject ()

@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) id object;
@property (nonatomic, copy) NSDictionary *userInfo;
@property (nonatomic, weak) __kindof UIView *view;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, assign) NSInteger triggerCount;
@property (nonatomic, assign) NSTimeInterval triggerDuration;
@property (nonatomic, assign) NSTimeInterval totalDuration;
@property (nonatomic, assign) BOOL isExposure;
@property (nonatomic, assign) BOOL isFinished;

@end

@implementation FWStatisticalObject

- (instancetype)initWithName:(NSString *)name
{
    return [self initWithName:name object:nil];
}

- (instancetype)initWithName:(NSString *)name object:(id)object
{
    return [self initWithName:name object:object userInfo:nil];
}

- (instancetype)initWithName:(NSString *)name object:(id)object userInfo:(NSDictionary *)userInfo
{
    self = [super init];
    if (self) {
        _name = [name copy];
        _object = object;
        _userInfo = [userInfo copy];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    FWStatisticalObject *object = [[[self class] allocWithZone:zone] init];
    object.name = [self.name copy];
    object.object = self.object;
    object.userInfo = [self.userInfo copy];
    object.triggerOnce = self.triggerOnce;
    object.triggerIgnored = self.triggerIgnored;
    object.shieldView = self.shieldView;
    object.shieldViewBlock = self.shieldViewBlock;
    return object;
}

@end

#pragma mark - UIView+FWStatistical

@implementation UIView (FWStatistical)

- (FWStatisticalObject *)fwStatisticalClick
{
    return objc_getAssociatedObject(self, @selector(fwStatisticalClick));
}

- (void)setFwStatisticalClick:(FWStatisticalObject *)fwStatisticalClick
{
    objc_setAssociatedObject(self, @selector(fwStatisticalClick), fwStatisticalClick, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self fwStatisticalClickRegister];
}

- (FWStatisticalBlock)fwStatisticalClickBlock
{
    return objc_getAssociatedObject(self, @selector(fwStatisticalClickBlock));
}

- (void)setFwStatisticalClickBlock:(FWStatisticalBlock)fwStatisticalClickBlock
{
    objc_setAssociatedObject(self, @selector(fwStatisticalClickBlock), fwStatisticalClickBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self fwStatisticalClickRegister];
}

- (BOOL)fwStatisticalClickIsRegistered
{
    return [objc_getAssociatedObject(self, @selector(fwStatisticalClickIsRegistered)) boolValue];
}

#pragma mark - Private

- (void)fwStatisticalClickRegister
{
    if ([self fwStatisticalClickIsRegistered]) return;
    objc_setAssociatedObject(self, @selector(fwStatisticalClickIsRegistered), @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if ([self isKindOfClass:[UITableViewCell class]] || [self isKindOfClass:[UICollectionViewCell class]]) {
        [self fwStatisticalClickCellRegister];
        return;
    }
    
    if ([self conformsToProtocol:@protocol(FWStatisticalDelegate)] &&
        [self respondsToSelector:@selector(statisticalClickWithCallback:)]) {
        __weak __typeof__(self) self_weak_ = self;
        [(id<FWStatisticalDelegate>)self statisticalClickWithCallback:^(__kindof UIView * _Nullable cell, NSIndexPath * _Nullable indexPath) {
            __typeof__(self) self = self_weak_;
            [self fwStatisticalTriggerClick:cell indexPath:indexPath];
        }];
        return;
    }
    
    if ([self isKindOfClass:[UITableView class]]) {
        FWSwizzleMethod(((UITableView *)self).delegate, @selector(tableView:didSelectRowAtIndexPath:), @"FWStatisticalManager", FWSwizzleType(NSObject<UITableViewDelegate> *), FWSwizzleReturn(void), FWSwizzleArgs(UITableView *tableView, NSIndexPath *indexPath), FWSwizzleCode({
            FWSwizzleOriginal(tableView, indexPath);
            
            if (![selfObject.fw isSwizzleInstanceMethod:@selector(tableView:didSelectRowAtIndexPath:) identifier:@"FWStatisticalManager"]) return;
            if (![tableView fwStatisticalClickIsRegistered]) return;
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            [tableView fwStatisticalTriggerClick:cell indexPath:indexPath];
        }));
        return;
    }
    
    if ([self isKindOfClass:[UICollectionView class]]) {
        FWSwizzleMethod(((UICollectionView *)self).delegate, @selector(collectionView:didSelectItemAtIndexPath:), @"FWStatisticalManager", FWSwizzleType(NSObject<UICollectionViewDelegate> *), FWSwizzleReturn(void), FWSwizzleArgs(UICollectionView *collectionView, NSIndexPath *indexPath), FWSwizzleCode({
            FWSwizzleOriginal(collectionView, indexPath);
            
            if (![selfObject.fw isSwizzleInstanceMethod:@selector(collectionView:didSelectItemAtIndexPath:) identifier:@"FWStatisticalManager"]) return;
            if (![collectionView fwStatisticalClickIsRegistered]) return;
            UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
            [collectionView fwStatisticalTriggerClick:cell indexPath:indexPath];
        }));
        return;
    }
    
    if ([self isKindOfClass:[UIControl class]]) {
        UIControlEvents controlEvents = UIControlEventTouchUpInside;
        if ([self isKindOfClass:[UIDatePicker class]] ||
            [self isKindOfClass:[UIPageControl class]] ||
            [self isKindOfClass:[UISegmentedControl class]] ||
            [self isKindOfClass:[UISlider class]] ||
            [self isKindOfClass:[UIStepper class]] ||
            [self isKindOfClass:[UISwitch class]] ||
            [self isKindOfClass:[UITextField class]]) {
            controlEvents = UIControlEventValueChanged;
        }
        [(UIControl *)self fwAddBlock:^(UIControl *sender) {
            [sender fwStatisticalTriggerClick:nil indexPath:nil];
        } forControlEvents:controlEvents];
        return;
    }
    
    for (UIGestureRecognizer *gesture in self.gestureRecognizers) {
        if ([gesture isKindOfClass:[UITapGestureRecognizer class]]) {
            [gesture fwAddBlock:^(UIGestureRecognizer *sender) {
                [sender.view fwStatisticalTriggerClick:nil indexPath:nil];
            }];
        }
    }
}

- (void)fwStatisticalClickCellRegister
{
    if (!self.superview) return;
    UIView *proxyView = nil;
    if ([self conformsToProtocol:@protocol(FWStatisticalDelegate)] &&
        [self respondsToSelector:@selector(statisticalCellProxyView)]) {
        proxyView = [(id<FWStatisticalDelegate>)self statisticalCellProxyView];
    } else {
        proxyView = [self isKindOfClass:[UITableViewCell class]] ? [(UITableViewCell *)self fwTableView] : [(UICollectionViewCell *)self fwCollectionView];
    }
    [proxyView fwStatisticalClickRegister];
}

- (NSInteger)fwStatisticalClickCount:(NSIndexPath *)indexPath
{
    NSMutableDictionary *triggerDict = objc_getAssociatedObject(self, _cmd);
    if (!triggerDict) {
        triggerDict = [[NSMutableDictionary alloc] init];
        objc_setAssociatedObject(self, _cmd, triggerDict, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    NSString *triggerKey = [NSString stringWithFormat:@"%@.%@", @(indexPath.section), @(indexPath.row)];
    NSInteger triggerCount = [[triggerDict objectForKey:triggerKey] integerValue] + 1;
    [triggerDict setObject:@(triggerCount) forKey:triggerKey];
    return triggerCount;
}

- (void)fwStatisticalTriggerClick:(UIView *)cell indexPath:(NSIndexPath *)indexPath
{
    FWStatisticalObject *object = cell.fwStatisticalClick ?: self.fwStatisticalClick;
    if (!object) object = [FWStatisticalObject new];
    if (object.triggerIgnored) return;
    NSInteger triggerCount = [self fwStatisticalClickCount:indexPath];
    if (triggerCount > 1 && object.triggerOnce) return;
    
    object.view = self;
    object.indexPath = indexPath;
    object.triggerCount = triggerCount;
    object.isExposure = NO;
    object.isFinished = YES;
    
    if (cell.fwStatisticalClickBlock) {
        cell.fwStatisticalClickBlock(object);
    } else if (self.fwStatisticalClickBlock) {
        self.fwStatisticalClickBlock(object);
    }
    if (cell.fwStatisticalClick || self.fwStatisticalClick) {
        [[FWStatisticalManager sharedInstance] handleEvent:object];
    }
}

@end

#pragma mark - UIView+FWExposure

typedef NS_ENUM(NSInteger, FWStatisticalExposureState) {
    FWStatisticalExposureStateNone,
    FWStatisticalExposureStatePartly,
    FWStatisticalExposureStateFully,
};

@implementation UIView (FWExposure)

#pragma mark - Hook

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        FWSwizzleClass(UIView, @selector(setFrame:), FWSwizzleReturn(void), FWSwizzleArgs(CGRect frame), FWSwizzleCode({
            FWSwizzleOriginal(frame);
            [selfObject fwStatisticalExposureUpdate];
        }));
        FWSwizzleClass(UIView, @selector(setHidden:), FWSwizzleReturn(void), FWSwizzleArgs(BOOL hidden), FWSwizzleCode({
            FWSwizzleOriginal(hidden);
            [selfObject fwStatisticalExposureUpdate];
        }));
        FWSwizzleClass(UIView, @selector(setAlpha:), FWSwizzleReturn(void), FWSwizzleArgs(CGFloat alpha), FWSwizzleCode({
            FWSwizzleOriginal(alpha);
            [selfObject fwStatisticalExposureUpdate];
        }));
        FWSwizzleClass(UIView, @selector(setBounds:), FWSwizzleReturn(void), FWSwizzleArgs(CGRect bounds), FWSwizzleCode({
            FWSwizzleOriginal(bounds);
            [selfObject fwStatisticalExposureUpdate];
        }));
        FWSwizzleClass(UIView, @selector(didMoveToWindow), FWSwizzleReturn(void), FWSwizzleArgs(), FWSwizzleCode({
            FWSwizzleOriginal();
            [selfObject fwStatisticalExposureUpdate];
        }));
        
        FWSwizzleClass(UITableView, @selector(reloadData), FWSwizzleReturn(void), FWSwizzleArgs(), FWSwizzleCode({
            FWSwizzleOriginal();
            [selfObject fwStatisticalExposureUpdate];
        }));
        FWSwizzleClass(UICollectionView, @selector(reloadData), FWSwizzleReturn(void), FWSwizzleArgs(), FWSwizzleCode({
            FWSwizzleOriginal();
            [selfObject fwStatisticalExposureUpdate];
        }));
        FWSwizzleClass(UITableViewCell, @selector(didMoveToSuperview), FWSwizzleReturn(void), FWSwizzleArgs(), FWSwizzleCode({
            FWSwizzleOriginal();
            
            if (selfObject.fwStatisticalClick || selfObject.fwStatisticalClickBlock) {
                [selfObject fwStatisticalClickCellRegister];
            }
            if (selfObject.fwStatisticalExposure || selfObject.fwStatisticalExposureBlock) {
                [selfObject fwStatisticalExposureCellRegister];
            }
        }));
        FWSwizzleClass(UICollectionViewCell, @selector(didMoveToSuperview), FWSwizzleReturn(void), FWSwizzleArgs(), FWSwizzleCode({
            FWSwizzleOriginal();
            
            if (selfObject.fwStatisticalClick || selfObject.fwStatisticalClickBlock) {
                [selfObject fwStatisticalClickCellRegister];
            }
            if (selfObject.fwStatisticalExposure || selfObject.fwStatisticalExposureBlock) {
                [selfObject fwStatisticalExposureCellRegister];
            }
        }));
    });
}

#pragma mark - Exposure

- (FWStatisticalObject *)fwStatisticalExposure
{
    return objc_getAssociatedObject(self, @selector(fwStatisticalExposure));
}

- (void)setFwStatisticalExposure:(FWStatisticalObject *)fwStatisticalExposure
{
    objc_setAssociatedObject(self, @selector(fwStatisticalExposure), fwStatisticalExposure, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self fwStatisticalExposureRegister];
}

- (FWStatisticalBlock)fwStatisticalExposureBlock
{
    return objc_getAssociatedObject(self, @selector(fwStatisticalExposureBlock));
}

- (void)setFwStatisticalExposureBlock:(FWStatisticalBlock)fwStatisticalExposureBlock
{
    objc_setAssociatedObject(self, @selector(fwStatisticalExposureBlock), fwStatisticalExposureBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self fwStatisticalExposureRegister];
}

#pragma mark - Accessor

- (BOOL)fwStatisticalExposureIsRegistered
{
    return [objc_getAssociatedObject(self, @selector(fwStatisticalExposureIsRegistered)) boolValue];
}

- (BOOL)fwStatisticalExposureIsProxy
{
    return [objc_getAssociatedObject(self, @selector(fwStatisticalExposureIsProxy)) boolValue];
}

- (void)setFwStatisticalExposureIsProxy:(BOOL)isProxy
{
    objc_setAssociatedObject(self, @selector(fwStatisticalExposureIsProxy), @(isProxy), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)fwStatisticalExposureIsFully
{
    return [objc_getAssociatedObject(self, @selector(fwStatisticalExposureIsFully)) boolValue];
}

- (void)setFwStatisticalExposureIsFully:(BOOL)isFully
{
    objc_setAssociatedObject(self, @selector(fwStatisticalExposureIsFully), @(isFully), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)fwStatisticalExposureIdentifier
{
    NSIndexPath *indexPath = nil;
    if ([self isKindOfClass:[UITableViewCell class]] || [self isKindOfClass:[UICollectionViewCell class]]) {
        indexPath = [(UITableViewCell *)self fwIndexPath];
    }
    
    NSString *identifier = [NSString stringWithFormat:@"%@-%@-%@-%@", @(indexPath.section), @(indexPath.row), self.fwStatisticalExposure.name, self.fwStatisticalExposure.object];
    return identifier;
}

- (BOOL)fwStatisticalExposureCustom
{
    if ([self conformsToProtocol:@protocol(FWStatisticalDelegate)] &&
        [self respondsToSelector:@selector(statisticalExposureWithCallback:)]) {
        __weak __typeof__(self) self_weak_ = self;
        [(id<FWStatisticalDelegate>)self statisticalExposureWithCallback:^(__kindof UIView * _Nullable cell, NSIndexPath * _Nullable indexPath, NSTimeInterval duration) {
            __typeof__(self) self = self_weak_;
            if ([self fwStatisticalExposureFullyState:[self fwStatisticalExposureState]]) {
                [self fwStatisticalTriggerExposure:cell indexPath:indexPath duration:duration];
            }
        }];
        return YES;
    }
    return NO;
}

- (FWStatisticalExposureState)fwStatisticalExposureState
{
    if (!self.fwIsViewVisible) {
        return FWStatisticalExposureStateNone;
    }
    
    UIViewController *viewController = self.fwViewController;
    if (viewController && (!viewController.view.window || viewController.presentedViewController)) {
        return FWStatisticalExposureStateNone;
    }
    
    UIView *targetView = viewController.view ?: self.window;
    UIView *superview = self.superview;
    BOOL superviewHidden = NO;
    while (superview && superview != targetView) {
        if (!superview.fwIsViewVisible) {
            superviewHidden = YES;
            break;
        }
        superview = superview.superview;
    }
    if (superviewHidden) {
        return FWStatisticalExposureStateNone;
    }
    
    CGRect viewRect = [self convertRect:self.bounds toView:targetView];
    viewRect = CGRectMake(floor(viewRect.origin.x), floor(viewRect.origin.y), floor(viewRect.size.width), floor(viewRect.size.height));
    CGRect targetRect = targetView.bounds;
    FWStatisticalExposureState state = FWStatisticalExposureStateNone;
    if (!CGRectIsEmpty(viewRect)) {
        if (CGRectContainsRect(targetRect, viewRect)) {
            state = FWStatisticalExposureStateFully;
        } else if (CGRectIntersectsRect(targetRect, viewRect)) {
            state = FWStatisticalExposureStatePartly;
        }
    }
    if (state == FWStatisticalExposureStateNone) {
        return state;
    }
    
    UIView *shieldView = nil;
    if (self.fwStatisticalExposure.shieldView) {
        shieldView = self.fwStatisticalExposure.shieldView;
    } else if (self.fwStatisticalExposure.shieldViewBlock) {
        shieldView = self.fwStatisticalExposure.shieldViewBlock();
    }
    if (!shieldView || !shieldView.fwIsViewVisible) {
        return state;
    }
    CGRect shieldRect = [shieldView convertRect:shieldView.bounds toView:targetView];
    if (!CGRectIsEmpty(shieldRect)) {
        if (CGRectContainsRect(shieldRect, viewRect)) {
            return FWStatisticalExposureStateNone;
        } else if (CGRectIntersectsRect(shieldRect, viewRect)) {
            return FWStatisticalExposureStatePartly;
        }
    }
    return state;
}

- (void)setFwStatisticalExposureState
{
    NSString *oldIdentifier = objc_getAssociatedObject(self, @selector(fwStatisticalExposureIdentifier)) ?: @"";
    NSString *identifier = [self fwStatisticalExposureIdentifier];
    BOOL identifierChanged = oldIdentifier.length > 0 && ![identifier isEqualToString:oldIdentifier];
    if (oldIdentifier.length < 1 || identifierChanged) {
        objc_setAssociatedObject(self, @selector(fwStatisticalExposureIdentifier), identifier, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        if (oldIdentifier.length < 1) [self fwStatisticalExposureCustom];
    }
    
    FWStatisticalExposureState oldState = [objc_getAssociatedObject(self, @selector(fwStatisticalExposureState)) integerValue];
    FWStatisticalExposureState state = [self fwStatisticalExposureState];
    if (state == oldState && !identifierChanged) return;
    objc_setAssociatedObject(self, @selector(fwStatisticalExposureState), @(state), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if ([self fwStatisticalExposureFullyState:state] &&
        (![self fwStatisticalExposureIsFully] || identifierChanged)) {
        [self setFwStatisticalExposureIsFully:YES];
        if ([self fwStatisticalExposureCustom]) {
        } else if ([self isKindOfClass:[UITableViewCell class]]) {
            [((UITableViewCell *)self).fwTableView fwStatisticalTriggerExposure:self indexPath:((UITableViewCell *)self).fwIndexPath duration:0];
        } else if ([self isKindOfClass:[UICollectionViewCell class]]) {
            [((UICollectionViewCell *)self).fwCollectionView fwStatisticalTriggerExposure:self indexPath:((UICollectionViewCell *)self).fwIndexPath duration:0];
        } else {
            [self fwStatisticalTriggerExposure:nil indexPath:nil duration:0];
        }
    } else if (state == FWStatisticalExposureStateNone || identifierChanged) {
        [self setFwStatisticalExposureIsFully:NO];
    }
}

- (BOOL)fwStatisticalExposureFullyState:(FWStatisticalExposureState)state
{
    BOOL isFullyState = (state == FWStatisticalExposureStateFully);
    if (!isFullyState && FWStatisticalManager.sharedInstance.exposurePartly) {
        isFullyState = (state == FWStatisticalExposureStatePartly);
    }
    return isFullyState;
}

#pragma mark - Private

- (void)fwStatisticalExposureRegister
{
    if ([self fwStatisticalExposureIsRegistered]) return;
    objc_setAssociatedObject(self, @selector(fwStatisticalExposureIsRegistered), @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if ([self isKindOfClass:[UITableViewCell class]] || [self isKindOfClass:[UICollectionViewCell class]]) {
        [self fwStatisticalExposureCellRegister];
        return;
    }
    
    if (self.superview) {
        [self.superview fwStatisticalExposureRegister];
    }
    
    if (self.fwStatisticalExposure || self.fwStatisticalExposureBlock || [self fwStatisticalExposureIsProxy]) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(fwStatisticalExposureCalculate) object:nil];
        [self performSelector:@selector(fwStatisticalExposureCalculate) withObject:nil afterDelay:0 inModes:@[FWStatisticalManager.sharedInstance.runLoopMode]];
    }
}

- (void)fwStatisticalExposureCellRegister
{
    if (!self.superview) return;
    UIView *proxyView = nil;
    if ([self conformsToProtocol:@protocol(FWStatisticalDelegate)] &&
        [self respondsToSelector:@selector(statisticalCellProxyView)]) {
        proxyView = [(id<FWStatisticalDelegate>)self statisticalCellProxyView];
    } else {
        proxyView = [self isKindOfClass:[UITableViewCell class]] ? [(UITableViewCell *)self fwTableView] : [(UICollectionViewCell *)self fwCollectionView];
    }
    [proxyView setFwStatisticalExposureIsProxy:YES];
    [proxyView fwStatisticalExposureRegister];
}

- (void)fwStatisticalExposureUpdate
{
    if (![self fwStatisticalExposureIsRegistered]) return;
    
    UIViewController *viewController = self.fwViewController;
    if (viewController && (!viewController.view.window || viewController.presentedViewController)) return;
    
    [self fwStatisticalExposureRecursive];
}

- (void)fwStatisticalExposureRecursive
{
    if (![self fwStatisticalExposureIsRegistered]) return;

    if (self.fwStatisticalExposure || self.fwStatisticalExposureBlock || [self fwStatisticalExposureIsProxy]) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(fwStatisticalExposureCalculate) object:nil];
        [self performSelector:@selector(fwStatisticalExposureCalculate) withObject:nil afterDelay:0 inModes:@[FWStatisticalManager.sharedInstance.runLoopMode]];
    }
    
    [self.subviews enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
        [obj fwStatisticalExposureRecursive];
    }];
}

- (void)fwStatisticalExposureCalculate
{
    if ([self isKindOfClass:[UITableView class]] || [self isKindOfClass:[UICollectionView class]]) {
        [self.subviews enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
            [obj setFwStatisticalExposureState];
        }];
    } else {
        [self setFwStatisticalExposureState];
    }
}

- (NSInteger)fwStatisticalExposureCount:(NSIndexPath *)indexPath
{
    NSMutableDictionary *triggerDict = objc_getAssociatedObject(self, _cmd);
    if (!triggerDict) {
        triggerDict = [[NSMutableDictionary alloc] init];
        objc_setAssociatedObject(self, _cmd, triggerDict, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    NSString *triggerKey = [NSString stringWithFormat:@"%@.%@", @(indexPath.section), @(indexPath.row)];
    NSInteger triggerCount = [[triggerDict objectForKey:triggerKey] integerValue] + 1;
    [triggerDict setObject:@(triggerCount) forKey:triggerKey];
    return triggerCount;
}

- (NSTimeInterval)fwStatisticalExposureDuration:(NSTimeInterval)duration indexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *triggerDict = objc_getAssociatedObject(self, _cmd);
    if (!triggerDict) {
        triggerDict = [[NSMutableDictionary alloc] init];
        objc_setAssociatedObject(self, _cmd, triggerDict, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    NSString *triggerKey = [NSString stringWithFormat:@"%@.%@", @(indexPath.section), @(indexPath.row)];
    NSTimeInterval triggerDuration = [[triggerDict objectForKey:triggerKey] doubleValue] + duration;
    [triggerDict setObject:@(triggerDuration) forKey:triggerKey];
    return triggerDuration;
}

- (void)fwStatisticalTriggerExposure:(UIView *)cell indexPath:(NSIndexPath *)indexPath duration:(NSTimeInterval)duration
{
    FWStatisticalObject *object = cell.fwStatisticalExposure ?: self.fwStatisticalExposure;
    if (!object) object = [FWStatisticalObject new];
    if (object.triggerIgnored) return;
    NSInteger triggerCount = [self fwStatisticalExposureCount:indexPath];
    if (triggerCount > 1 && object.triggerOnce) return;
    
    object.view = self;
    object.indexPath = indexPath;
    object.triggerCount = triggerCount;
    object.triggerDuration = duration;
    object.totalDuration = [self fwStatisticalExposureDuration:duration indexPath:indexPath];
    object.isExposure = YES;
    object.isFinished = duration > 0;
    
    if (cell.fwStatisticalExposureBlock) {
        cell.fwStatisticalExposureBlock(object);
    } else if (self.fwStatisticalExposureBlock) {
        self.fwStatisticalExposureBlock(object);
    }
    if (cell.fwStatisticalExposure || self.fwStatisticalExposure) {
        [[FWStatisticalManager sharedInstance] handleEvent:object];
    }
}

@end
