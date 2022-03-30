/**
 @header     NSArray+FWApplication.h
 @indexgroup FWApplication
      NSArray分类
 @author     wuyong
 @copyright  Copyright © 2018年 wuyong.site. All rights reserved.
 @updated    2018-09-17
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 NSArray分类
 @note 如果需要数组weak引用元素，使用[NSValue valueWithNonretainedObject:object]即可
 */
@interface NSArray<__covariant ObjectType> (FWApplication)

/**
 从数组中按照权重随机取出对象，如@[@"a", @"b", @"c"]按照@[@0, @8, @02]大概率取出@"b"，不会取出@"a"
 
 @param weights 权重数组，按整数计算
 @return 随机对象
 */
- (nullable ObjectType)fwRandomObject:(NSArray *)weights;

/**
 获取翻转后的新数组
 
 @return 翻转后的数组
 */
@property (nonatomic, copy, readonly) NSArray<ObjectType> *fwReverseArray;

/**
 获取打乱后的新数组
 
 @return 打乱后的数组
 */
@property (nonatomic, copy, readonly) NSArray<ObjectType> *fwShuffleArray;

/**
 数组中是否含有NSNull值
 
 @return 是否含有NSNull
 */
@property (nonatomic, assign, readonly) BOOL fwIncludeNull;

/**
 递归移除数组中NSNull值
 
 @return 不含NSNull的数组
 */
@property (nonatomic, copy, readonly) NSArray<ObjectType> *fwRemoveNull;

/**
 移除数组中NSNull值
 
 @praram recursive 是否递归
 @return 不含NSNull的数组
 */
- (NSArray<ObjectType> *)fwRemoveNullRecursive:(BOOL)recursive;

@end

#pragma mark - NSMutableArray+FWApplication

/**
 NSMutableArray分类
 */
@interface NSMutableArray<ObjectType> (FWApplication)

/**
 当前数组翻转
 */
- (void)fwReverse;

/**
 打乱当前数组
 */
- (void)fwShuffle;

@end

#pragma mark - FWMutableArray

/**
 线程安全的可变数组，参考自YYKit
 
 @see https://github.com/ibireme/YYKit
 */
@interface FWMutableArray<__covariant ObjectType> : NSMutableArray<ObjectType>

@end

NS_ASSUME_NONNULL_END
