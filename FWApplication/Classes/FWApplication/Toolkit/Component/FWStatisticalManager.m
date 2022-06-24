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

#pragma mark - FWStatistical

NSNotificationName const FWStatisticalEventTriggeredNotification = @"FWStatisticalEventTriggeredNotification";

@interface FWViewWrapper (FWStatisticalInternal)

+ (void)enableStatistical;

@end

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

- (void)setStatisticalEnabled:(BOOL)enabled
{
    _statisticalEnabled = enabled;
    if (enabled) [FWViewWrapper enableStatistical];
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

#pragma mark - FWViewWrapper+FWStatistical

@implementation FWViewWrapper (FWStatistical)

- (FWStatisticalObject *)statisticalClick
{
    return objc_getAssociatedObject(self.base, @selector(statisticalClick));
}

- (void)setStatisticalClick:(FWStatisticalObject *)statisticalClick
{
    objc_setAssociatedObject(self.base, @selector(statisticalClick), statisticalClick, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self statisticalClickRegister];
}

- (FWStatisticalBlock)statisticalClickBlock
{
    return objc_getAssociatedObject(self.base, @selector(statisticalClickBlock));
}

- (void)setStatisticalClickBlock:(FWStatisticalBlock)statisticalClickBlock
{
    objc_setAssociatedObject(self.base, @selector(statisticalClickBlock), statisticalClickBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self statisticalClickRegister];
}

- (BOOL)statisticalClickIsRegistered
{
    return [objc_getAssociatedObject(self.base, @selector(statisticalClickIsRegistered)) boolValue];
}

#pragma mark - Private

- (void)statisticalClickRegister
{
    if ([self statisticalClickIsRegistered]) return;
    objc_setAssociatedObject(self.base, @selector(statisticalClickIsRegistered), @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if ([self.base isKindOfClass:[UITableViewCell class]] || [self.base isKindOfClass:[UICollectionViewCell class]]) {
        [self statisticalClickCellRegister];
        return;
    }
    
    if ([self.base conformsToProtocol:@protocol(FWStatisticalDelegate)] &&
        [self.base respondsToSelector:@selector(statisticalClickWithCallback:)]) {
        __weak UIView *weakBase = self.base;
        [(id<FWStatisticalDelegate>)self.base statisticalClickWithCallback:^(__kindof UIView * _Nullable cell, NSIndexPath * _Nullable indexPath) {
            [weakBase.fw statisticalTriggerClick:cell indexPath:indexPath];
        }];
        return;
    }
    
    if ([self.base isKindOfClass:[UITableView class]]) {
        FWSwizzleMethod(((UITableView *)self.base).delegate, @selector(tableView:didSelectRowAtIndexPath:), @"FWStatisticalManager", FWSwizzleType(NSObject<UITableViewDelegate> *), FWSwizzleReturn(void), FWSwizzleArgs(UITableView *tableView, NSIndexPath *indexPath), FWSwizzleCode({
            FWSwizzleOriginal(tableView, indexPath);
            
            if (![selfObject fw_isSwizzleInstanceMethod:@selector(tableView:didSelectRowAtIndexPath:) identifier:@"FWStatisticalManager"]) return;
            if (![tableView.fw statisticalClickIsRegistered]) return;
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            [tableView.fw statisticalTriggerClick:cell indexPath:indexPath];
        }));
        return;
    }
    
    if ([self.base isKindOfClass:[UICollectionView class]]) {
        FWSwizzleMethod(((UICollectionView *)self.base).delegate, @selector(collectionView:didSelectItemAtIndexPath:), @"FWStatisticalManager", FWSwizzleType(NSObject<UICollectionViewDelegate> *), FWSwizzleReturn(void), FWSwizzleArgs(UICollectionView *collectionView, NSIndexPath *indexPath), FWSwizzleCode({
            FWSwizzleOriginal(collectionView, indexPath);
            
            if (![selfObject fw_isSwizzleInstanceMethod:@selector(collectionView:didSelectItemAtIndexPath:) identifier:@"FWStatisticalManager"]) return;
            if (![collectionView.fw statisticalClickIsRegistered]) return;
            UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
            [collectionView.fw statisticalTriggerClick:cell indexPath:indexPath];
        }));
        return;
    }
    
    if ([self.base isKindOfClass:[UIControl class]]) {
        UIControlEvents controlEvents = UIControlEventTouchUpInside;
        if ([self.base isKindOfClass:[UIDatePicker class]] ||
            [self.base isKindOfClass:[UIPageControl class]] ||
            [self.base isKindOfClass:[UISegmentedControl class]] ||
            [self.base isKindOfClass:[UISlider class]] ||
            [self.base isKindOfClass:[UIStepper class]] ||
            [self.base isKindOfClass:[UISwitch class]] ||
            [self.base isKindOfClass:[UITextField class]]) {
            controlEvents = UIControlEventValueChanged;
        }
        [((UIControl *)self.base) fw_addBlock:^(UIControl *sender) {
            [sender.fw statisticalTriggerClick:nil indexPath:nil];
        } forControlEvents:controlEvents];
        return;
    }
    
    for (UIGestureRecognizer *gesture in self.base.gestureRecognizers) {
        if ([gesture isKindOfClass:[UITapGestureRecognizer class]]) {
            [gesture fw_addBlock:^(UIGestureRecognizer *sender) {
                [sender.view.fw statisticalTriggerClick:nil indexPath:nil];
            }];
        }
    }
}

- (void)statisticalClickCellRegister
{
    if (!self.base.superview) return;
    UIView *proxyView = nil;
    if ([self.base conformsToProtocol:@protocol(FWStatisticalDelegate)] &&
        [self.base respondsToSelector:@selector(statisticalCellProxyView)]) {
        proxyView = [(id<FWStatisticalDelegate>)self.base statisticalCellProxyView];
    } else {
        proxyView = [self.base isKindOfClass:[UITableViewCell class]] ? [((UITableViewCell *)self.base).fw tableView] : [((UICollectionViewCell *)self.base).fw collectionView];
    }
    [proxyView.fw statisticalClickRegister];
}

- (NSInteger)statisticalClickCount:(NSIndexPath *)indexPath
{
    NSMutableDictionary *triggerDict = objc_getAssociatedObject(self.base, _cmd);
    if (!triggerDict) {
        triggerDict = [[NSMutableDictionary alloc] init];
        objc_setAssociatedObject(self.base, _cmd, triggerDict, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    NSString *triggerKey = [NSString stringWithFormat:@"%@.%@", @(indexPath.section), @(indexPath.row)];
    NSInteger triggerCount = [[triggerDict objectForKey:triggerKey] integerValue] + 1;
    [triggerDict setObject:@(triggerCount) forKey:triggerKey];
    return triggerCount;
}

- (void)statisticalTriggerClick:(UIView *)cell indexPath:(NSIndexPath *)indexPath
{
    FWStatisticalObject *object = cell.fw.statisticalClick ?: self.statisticalClick;
    if (!object) object = [FWStatisticalObject new];
    if (object.triggerIgnored) return;
    NSInteger triggerCount = [self statisticalClickCount:indexPath];
    if (triggerCount > 1 && object.triggerOnce) return;
    
    object.view = self.base;
    object.indexPath = indexPath;
    object.triggerCount = triggerCount;
    object.isExposure = NO;
    object.isFinished = YES;
    
    if (cell.fw.statisticalClickBlock) {
        cell.fw.statisticalClickBlock(object);
    } else if (self.statisticalClickBlock) {
        self.statisticalClickBlock(object);
    }
    if (cell.fw.statisticalClick || self.statisticalClick) {
        [[FWStatisticalManager sharedInstance] handleEvent:object];
    }
}

@end

#pragma mark - FWViewWrapper+FWExposure

@interface FWInnerStatisticalTarget : NSObject

@property (nonatomic, weak, readonly) UIView *view;

- (instancetype)initWithView:(UIView *)view;

- (void)statisticalExposureCalculate;

@end

typedef NS_ENUM(NSInteger, FWStatisticalExposureState) {
    FWStatisticalExposureStateNone,
    FWStatisticalExposureStatePartly,
    FWStatisticalExposureStateFully,
};

@implementation FWViewWrapper (FWExposure)

#pragma mark - Hook

+ (void)enableStatistical
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        FWSwizzleClass(UIView, @selector(setFrame:), FWSwizzleReturn(void), FWSwizzleArgs(CGRect frame), FWSwizzleCode({
            FWSwizzleOriginal(frame);
            [selfObject.fw statisticalExposureUpdate];
        }));
        FWSwizzleClass(UIView, @selector(setHidden:), FWSwizzleReturn(void), FWSwizzleArgs(BOOL hidden), FWSwizzleCode({
            FWSwizzleOriginal(hidden);
            [selfObject.fw statisticalExposureUpdate];
        }));
        FWSwizzleClass(UIView, @selector(setAlpha:), FWSwizzleReturn(void), FWSwizzleArgs(CGFloat alpha), FWSwizzleCode({
            FWSwizzleOriginal(alpha);
            [selfObject.fw statisticalExposureUpdate];
        }));
        FWSwizzleClass(UIView, @selector(setBounds:), FWSwizzleReturn(void), FWSwizzleArgs(CGRect bounds), FWSwizzleCode({
            FWSwizzleOriginal(bounds);
            [selfObject.fw statisticalExposureUpdate];
        }));
        FWSwizzleClass(UIView, @selector(didMoveToWindow), FWSwizzleReturn(void), FWSwizzleArgs(), FWSwizzleCode({
            FWSwizzleOriginal();
            [selfObject.fw statisticalExposureUpdate];
        }));
        
        FWSwizzleClass(UITableView, @selector(reloadData), FWSwizzleReturn(void), FWSwizzleArgs(), FWSwizzleCode({
            FWSwizzleOriginal();
            [selfObject.fw statisticalExposureUpdate];
        }));
        FWSwizzleClass(UICollectionView, @selector(reloadData), FWSwizzleReturn(void), FWSwizzleArgs(), FWSwizzleCode({
            FWSwizzleOriginal();
            [selfObject.fw statisticalExposureUpdate];
        }));
        FWSwizzleClass(UITableViewCell, @selector(didMoveToSuperview), FWSwizzleReturn(void), FWSwizzleArgs(), FWSwizzleCode({
            FWSwizzleOriginal();
            
            if (selfObject.fw.statisticalClick || selfObject.fw.statisticalClickBlock) {
                [selfObject.fw statisticalClickCellRegister];
            }
            if (selfObject.fw.statisticalExposure || selfObject.fw.statisticalExposureBlock) {
                [selfObject.fw statisticalExposureCellRegister];
            }
        }));
        FWSwizzleClass(UICollectionViewCell, @selector(didMoveToSuperview), FWSwizzleReturn(void), FWSwizzleArgs(), FWSwizzleCode({
            FWSwizzleOriginal();
            
            if (selfObject.fw.statisticalClick || selfObject.fw.statisticalClickBlock) {
                [selfObject.fw statisticalClickCellRegister];
            }
            if (selfObject.fw.statisticalExposure || selfObject.fw.statisticalExposureBlock) {
                [selfObject.fw statisticalExposureCellRegister];
            }
        }));
    });
}

#pragma mark - Exposure

- (FWStatisticalObject *)statisticalExposure
{
    return objc_getAssociatedObject(self.base, @selector(statisticalExposure));
}

- (void)setStatisticalExposure:(FWStatisticalObject *)statisticalExposure
{
    objc_setAssociatedObject(self.base, @selector(statisticalExposure), statisticalExposure, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self statisticalExposureRegister];
}

- (FWStatisticalBlock)statisticalExposureBlock
{
    return objc_getAssociatedObject(self.base, @selector(statisticalExposureBlock));
}

- (void)setStatisticalExposureBlock:(FWStatisticalBlock)statisticalExposureBlock
{
    objc_setAssociatedObject(self.base, @selector(statisticalExposureBlock), statisticalExposureBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self statisticalExposureRegister];
}

#pragma mark - Accessor

- (BOOL)statisticalExposureIsRegistered
{
    return [objc_getAssociatedObject(self.base, @selector(statisticalExposureIsRegistered)) boolValue];
}

- (BOOL)statisticalExposureIsProxy
{
    return [objc_getAssociatedObject(self.base, @selector(statisticalExposureIsProxy)) boolValue];
}

- (void)setStatisticalExposureIsProxy:(BOOL)isProxy
{
    objc_setAssociatedObject(self.base, @selector(statisticalExposureIsProxy), @(isProxy), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)statisticalExposureIsFully
{
    return [objc_getAssociatedObject(self.base, @selector(statisticalExposureIsFully)) boolValue];
}

- (void)setStatisticalExposureIsFully:(BOOL)isFully
{
    objc_setAssociatedObject(self.base, @selector(statisticalExposureIsFully), @(isFully), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)statisticalExposureIdentifier
{
    NSIndexPath *indexPath = nil;
    if ([self.base isKindOfClass:[UITableViewCell class]] || [self.base isKindOfClass:[UICollectionViewCell class]]) {
        indexPath = [((UITableViewCell *)self.base).fw indexPath];
    }
    
    NSString *identifier = [NSString stringWithFormat:@"%@-%@-%@-%@", @(indexPath.section), @(indexPath.row), self.statisticalExposure.name, self.statisticalExposure.object];
    return identifier;
}

- (BOOL)statisticalExposureCustom
{
    if ([self.base conformsToProtocol:@protocol(FWStatisticalDelegate)] &&
        [self.base respondsToSelector:@selector(statisticalExposureWithCallback:)]) {
        __weak UIView *weakBase = self.base;
        [(id<FWStatisticalDelegate>)self.base statisticalExposureWithCallback:^(__kindof UIView * _Nullable cell, NSIndexPath * _Nullable indexPath, NSTimeInterval duration) {
            if ([weakBase.fw statisticalExposureFullyState:[weakBase.fw statisticalExposureState]]) {
                [weakBase.fw statisticalTriggerExposure:cell indexPath:indexPath duration:duration];
            }
        }];
        return YES;
    }
    return NO;
}

- (FWStatisticalExposureState)statisticalExposureState
{
    if (!self.base.fw_isViewVisible) {
        return FWStatisticalExposureStateNone;
    }
    
    UIViewController *viewController = self.base.fw_viewController;
    if (viewController && (!viewController.view.window || viewController.presentedViewController)) {
        return FWStatisticalExposureStateNone;
    }
    
    UIView *targetView = viewController.view ?: self.base.window;
    UIView *superview = self.base.superview;
    BOOL superviewHidden = NO;
    while (superview && superview != targetView) {
        if (!superview.fw_isViewVisible) {
            superviewHidden = YES;
            break;
        }
        superview = superview.superview;
    }
    if (superviewHidden) {
        return FWStatisticalExposureStateNone;
    }
    
    CGRect viewRect = [self.base convertRect:self.base.bounds toView:targetView];
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
    if (self.statisticalExposure.shieldView) {
        shieldView = self.statisticalExposure.shieldView;
    } else if (self.statisticalExposure.shieldViewBlock) {
        shieldView = self.statisticalExposure.shieldViewBlock();
    }
    if (!shieldView || !shieldView.fw_isViewVisible) {
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

- (void)setStatisticalExposureState
{
    NSString *oldIdentifier = objc_getAssociatedObject(self.base, @selector(statisticalExposureIdentifier)) ?: @"";
    NSString *identifier = [self statisticalExposureIdentifier];
    BOOL identifierChanged = oldIdentifier.length > 0 && ![identifier isEqualToString:oldIdentifier];
    if (oldIdentifier.length < 1 || identifierChanged) {
        objc_setAssociatedObject(self.base, @selector(statisticalExposureIdentifier), identifier, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        if (oldIdentifier.length < 1) [self statisticalExposureCustom];
    }
    
    FWStatisticalExposureState oldState = [objc_getAssociatedObject(self.base, @selector(statisticalExposureState)) integerValue];
    FWStatisticalExposureState state = [self statisticalExposureState];
    if (state == oldState && !identifierChanged) return;
    objc_setAssociatedObject(self.base, @selector(statisticalExposureState), @(state), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if ([self statisticalExposureFullyState:state] &&
        (![self statisticalExposureIsFully] || identifierChanged)) {
        [self setStatisticalExposureIsFully:YES];
        if ([self statisticalExposureCustom]) {
        } else if ([self.base isKindOfClass:[UITableViewCell class]]) {
            [((UITableViewCell *)self.base).fw.tableView.fw statisticalTriggerExposure:self.base indexPath:((UITableViewCell *)self.base).fw.indexPath duration:0];
        } else if ([self.base isKindOfClass:[UICollectionViewCell class]]) {
            [((UICollectionViewCell *)self.base).fw.collectionView.fw statisticalTriggerExposure:self.base indexPath:((UICollectionViewCell *)self.base).fw.indexPath duration:0];
        } else {
            [self statisticalTriggerExposure:nil indexPath:nil duration:0];
        }
    } else if (state == FWStatisticalExposureStateNone || identifierChanged) {
        [self setStatisticalExposureIsFully:NO];
    }
}

- (BOOL)statisticalExposureFullyState:(FWStatisticalExposureState)state
{
    BOOL isFullyState = (state == FWStatisticalExposureStateFully);
    if (!isFullyState && FWStatisticalManager.sharedInstance.exposurePartly) {
        isFullyState = (state == FWStatisticalExposureStatePartly);
    }
    return isFullyState;
}

#pragma mark - Private

- (void)statisticalExposureRegister
{
    if ([self statisticalExposureIsRegistered]) return;
    objc_setAssociatedObject(self.base, @selector(statisticalExposureIsRegistered), @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if ([self.base isKindOfClass:[UITableViewCell class]] || [self.base isKindOfClass:[UICollectionViewCell class]]) {
        [self statisticalExposureCellRegister];
        return;
    }
    
    if (self.base.superview) {
        [self.base.superview.fw statisticalExposureRegister];
    }
    
    if (self.statisticalExposure || self.statisticalExposureBlock || [self statisticalExposureIsProxy]) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self.innerStatisticalTarget selector:@selector(statisticalExposureCalculate) object:nil];
        [self.innerStatisticalTarget performSelector:@selector(statisticalExposureCalculate) withObject:nil afterDelay:0 inModes:@[FWStatisticalManager.sharedInstance.runLoopMode]];
    }
}

- (void)statisticalExposureCellRegister
{
    if (!self.base.superview) return;
    UIView *proxyView = nil;
    if ([self.base conformsToProtocol:@protocol(FWStatisticalDelegate)] &&
        [self.base respondsToSelector:@selector(statisticalCellProxyView)]) {
        proxyView = [(id<FWStatisticalDelegate>)self.base statisticalCellProxyView];
    } else {
        proxyView = [self.base isKindOfClass:[UITableViewCell class]] ? [((UITableViewCell *)self.base).fw tableView] : [((UICollectionViewCell *)self.base).fw collectionView];
    }
    [proxyView.fw setStatisticalExposureIsProxy:YES];
    [proxyView.fw statisticalExposureRegister];
}

- (void)statisticalExposureUpdate
{
    if (![self statisticalExposureIsRegistered]) return;
    
    UIViewController *viewController = self.base.fw_viewController;
    if (viewController && (!viewController.view.window || viewController.presentedViewController)) return;
    
    [self statisticalExposureRecursive];
}

- (void)statisticalExposureRecursive
{
    if (![self statisticalExposureIsRegistered]) return;

    if (self.statisticalExposure || self.statisticalExposureBlock || [self statisticalExposureIsProxy]) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self.innerStatisticalTarget selector:@selector(statisticalExposureCalculate) object:nil];
        [self.innerStatisticalTarget performSelector:@selector(statisticalExposureCalculate) withObject:nil afterDelay:0 inModes:@[FWStatisticalManager.sharedInstance.runLoopMode]];
    }
    
    [self.base.subviews enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
        [obj.fw statisticalExposureRecursive];
    }];
}

- (FWInnerStatisticalTarget *)innerStatisticalTarget
{
    FWInnerStatisticalTarget *target = objc_getAssociatedObject(self.base, _cmd);
    if (!target) {
        target = [[FWInnerStatisticalTarget alloc] initWithView:self.base];
        objc_setAssociatedObject(self.base, _cmd, target, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return target;
}

- (NSInteger)statisticalExposureCount:(NSIndexPath *)indexPath
{
    NSMutableDictionary *triggerDict = objc_getAssociatedObject(self.base, _cmd);
    if (!triggerDict) {
        triggerDict = [[NSMutableDictionary alloc] init];
        objc_setAssociatedObject(self.base, _cmd, triggerDict, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    NSString *triggerKey = [NSString stringWithFormat:@"%@.%@", @(indexPath.section), @(indexPath.row)];
    NSInteger triggerCount = [[triggerDict objectForKey:triggerKey] integerValue] + 1;
    [triggerDict setObject:@(triggerCount) forKey:triggerKey];
    return triggerCount;
}

- (NSTimeInterval)statisticalExposureDuration:(NSTimeInterval)duration indexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *triggerDict = objc_getAssociatedObject(self.base, _cmd);
    if (!triggerDict) {
        triggerDict = [[NSMutableDictionary alloc] init];
        objc_setAssociatedObject(self.base, _cmd, triggerDict, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    NSString *triggerKey = [NSString stringWithFormat:@"%@.%@", @(indexPath.section), @(indexPath.row)];
    NSTimeInterval triggerDuration = [[triggerDict objectForKey:triggerKey] doubleValue] + duration;
    [triggerDict setObject:@(triggerDuration) forKey:triggerKey];
    return triggerDuration;
}

- (void)statisticalTriggerExposure:(UIView *)cell indexPath:(NSIndexPath *)indexPath duration:(NSTimeInterval)duration
{
    FWStatisticalObject *object = cell.fw.statisticalExposure ?: self.statisticalExposure;
    if (!object) object = [FWStatisticalObject new];
    if (object.triggerIgnored) return;
    NSInteger triggerCount = [self statisticalExposureCount:indexPath];
    if (triggerCount > 1 && object.triggerOnce) return;
    
    object.view = self.base;
    object.indexPath = indexPath;
    object.triggerCount = triggerCount;
    object.triggerDuration = duration;
    object.totalDuration = [self statisticalExposureDuration:duration indexPath:indexPath];
    object.isExposure = YES;
    object.isFinished = duration > 0;
    
    if (cell.fw.statisticalExposureBlock) {
        cell.fw.statisticalExposureBlock(object);
    } else if (self.statisticalExposureBlock) {
        self.statisticalExposureBlock(object);
    }
    if (cell.fw.statisticalExposure || self.statisticalExposure) {
        [[FWStatisticalManager sharedInstance] handleEvent:object];
    }
}

@end

@implementation FWInnerStatisticalTarget

- (instancetype)initWithView:(UIView *)view
{
    self = [super init];
    if (self) {
        _view = view;
    }
    return self;
}

- (void)statisticalExposureCalculate
{
    if ([self.view isKindOfClass:[UITableView class]] || [self.view isKindOfClass:[UICollectionView class]]) {
        [self.view.subviews enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
            [obj.fw setStatisticalExposureState];
        }];
    } else {
        [self.view.fw setStatisticalExposureState];
    }
}

@end
