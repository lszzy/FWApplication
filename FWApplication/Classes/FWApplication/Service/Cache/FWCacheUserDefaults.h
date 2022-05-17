//
//  FWCacheDefaults.h
//  FWApplication
//
//  Created by wuyong on 2017/5/10.
//  Copyright © 2018年 wuyong.site. All rights reserved.
//

#import "FWCacheEngine.h"

NS_ASSUME_NONNULL_BEGIN

/// NSUserDefaults缓存
NS_SWIFT_NAME(CacheUserDefaults)
@interface FWCacheUserDefaults : FWCacheEngine

/** 单例模式 */
@property (class, nonatomic, readonly) FWCacheUserDefaults *sharedInstance;

/// 分组对象
- (instancetype)initWithGroup:(nullable NSString *)group;

@end

NS_ASSUME_NONNULL_END
