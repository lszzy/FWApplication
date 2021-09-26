/*!
 @header     NSArray+FWApplication.h
 @indexgroup FWApplication
 @brief      NSArray分类
 @author     wuyong
 @copyright  Copyright © 2018年 wuyong.site. All rights reserved.
 @updated    2018-09-17
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 @brief NSArray分类
 @discussion 如果需要数组weak引用元素，使用[NSValue valueWithNonretainedObject:object]即可
 */
@interface NSArray<__covariant ObjectType> (FWApplication)

/*!
 @brief 从数组中按照权重随机取出对象，如@[@"a", @"b", @"c"]按照@[@0, @8, @02]大概率取出@"b"，不会取出@"a"
 
 @param weights 权重数组，按整数计算
 @return 随机对象
 */
- (nullable ObjectType)fwRandomObject:(NSArray *)weights;

/*!
 @brief 获取翻转后的新数组
 
 @return 翻转后的数组
 */
@property (nonatomic, copy, readonly) NSArray<ObjectType> *fwReverseArray;

/*!
 @brief 获取打乱后的新数组
 
 @return 打乱后的数组
 */
@property (nonatomic, copy, readonly) NSArray<ObjectType> *fwShuffleArray;

/*!
 @brief 数组中是否含有NSNull值
 
 @return 是否含有NSNull
 */
@property (nonatomic, assign, readonly) BOOL fwIncludeNull;

/*!
 @brief 递归移除数组中NSNull值
 
 @return 不含NSNull的数组
 */
@property (nonatomic, copy, readonly) NSArray<ObjectType> *fwRemoveNull;

/*!
 @brief 移除数组中NSNull值
 
 @praram recursive 是否递归
 @return 不含NSNull的数组
 */
- (NSArray<ObjectType> *)fwRemoveNullRecursive:(BOOL)recursive;

@end

#pragma mark - NSMutableArray+FWApplication

/*!
 @brief NSMutableArray分类
 */
@interface NSMutableArray<ObjectType> (FWApplication)

/*!
 @brief 当前数组翻转
 */
- (void)fwReverse;

/*!
 @brief 打乱当前数组
 */
- (void)fwShuffle;

@end

#pragma mark - FWMutableArray

/*!
 @brief 线程安全的可变数组，参考自YYKit
 
 @see https://github.com/ibireme/YYKit
 */
@interface FWMutableArray : NSMutableArray

@end

NS_ASSUME_NONNULL_END
