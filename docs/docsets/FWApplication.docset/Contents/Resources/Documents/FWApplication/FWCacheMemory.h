//
//  FWCacheMemory.h
//  FWApplication
//
//  Created by wuyong on 2017/5/10.
//  Copyright © 2018年 wuyong.site. All rights reserved.
//

#import "FWCacheEngine.h"

NS_ASSUME_NONNULL_BEGIN

/// 内存缓存
NS_SWIFT_NAME(CacheMemory)
@interface FWCacheMemory : FWCacheEngine

/** 单例模式 */
@property (class, nonatomic, readonly) FWCacheMemory *sharedInstance;

@end

NS_ASSUME_NONNULL_END
