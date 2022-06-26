/**
 @header     NSDictionary+FWApplication.h
 @indexgroup FWApplication
      NSDictionary分类
 @author     wuyong
 @copyright  Copyright © 2018年 wuyong.site. All rights reserved.
 @updated    2018-09-17
 */

@import FWFramework;

NS_ASSUME_NONNULL_BEGIN

/**
 NSDictionary分类
 */
@interface NSDictionary<__covariant KeyType, __covariant ObjectType> (FWApplication)

/**
 从字典中随机取出Key，如@{@"a"=>@2, @"b"=>@8, @"c"=>@0}随机取出@"b"
 
 @return 随机Key
 */
@property (nonatomic, readonly, nullable) KeyType fw_randomKey NS_REFINED_FOR_SWIFT;

/**
 从字典中随机取出对象，如@{@"a"=>@2, @"b"=>@8, @"c"=>@0}随机取出@8
 
 @return 随机对象
 */
@property (nonatomic, readonly, nullable) ObjectType fw_randomObject NS_REFINED_FOR_SWIFT;

/**
 从字典中按权重Object随机取出Key，如@{@"a"=>@2, @"b"=>@8, @"c"=>@0}大概率取出@"b"，不会取出@"c"
 
 @return 随机Key
 */
@property (nonatomic, readonly, nullable) KeyType fw_randomWeightKey NS_REFINED_FOR_SWIFT;

/**
 字典中是否含有NSNull值
 
 @return 是否含有NSNull
 */
@property (nonatomic, assign, readonly) BOOL fw_includeNull NS_REFINED_FOR_SWIFT;

/**
 递归移除字典中NSNull值
 
 @return 不含NSNull的字典
 */
@property (nonatomic, copy, readonly) NSDictionary<KeyType, ObjectType> *fw_removeNull NS_REFINED_FOR_SWIFT;

/**
 移除字典中NSNull值
 
 @praram recursive 是否递归
 @return 不含NSNull的字典
 */
- (NSDictionary<KeyType, ObjectType> *)fw_removeNullRecursive:(BOOL)recursive NS_REFINED_FOR_SWIFT;

@end

#pragma mark - FWMutableDictionary

/**
 线程安全的可变字典，参考自YYKit
 
 @see https://github.com/ibireme/YYKit
 */
NS_SWIFT_NAME(MutableDictionary)
@interface FWMutableDictionary<__covariant KeyType, __covariant ObjectType> : NSMutableDictionary<KeyType, ObjectType>

@end

NS_ASSUME_NONNULL_END
