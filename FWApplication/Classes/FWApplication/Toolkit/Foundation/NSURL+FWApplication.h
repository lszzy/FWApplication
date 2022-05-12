/**
 @header     NSURL+FWApplication.h
 @indexgroup FWApplication
      NSURL+FWApplication
 @author     wuyong
 @copyright  Copyright © 2018 wuyong.site. All rights reserved.
 @updated    2018/12/3
 */

@import FWFramework;

NS_ASSUME_NONNULL_BEGIN

/**
 第三方URL生成器，可先判断canOpenURL，再openURL，需添加对应URL SCHEME到LSApplicationQueriesSchemes配置数组
 */
@interface FWURLClassWrapper (FWApplication)

#pragma mark - Map

/**
 生成苹果地图地址外部URL
 
 @param addr 显示地址，格式latitude,longitude或搜索地址
 @param options 可选附加参数，如@{@"ll": @"latitude,longitude", @"z": @"14"}
 @return NSURL
 */
- (nullable NSURL *)appleMapsURLWithAddr:(nullable NSString *)addr options:(nullable NSDictionary *)options;

/**
 生成苹果地图导航外部URL
 
 @param saddr 导航起始点，格式latitude,longitude或搜索地址
 @param daddr 导航结束点，格式latitude,longitude或搜索地址
 @param options 可选附加参数，如@{@"ll": @"latitude,longitude", @"z": @"14"}
 @return NSURL
 */
- (nullable NSURL *)appleMapsURLWithSaddr:(nullable NSString *)saddr daddr:(nullable NSString *)daddr options:(nullable NSDictionary *)options;

/**
 生成谷歌地图外部URL，URL SCHEME为：comgooglemaps
 
 @param addr 显示地址，格式latitude,longitude或搜索地址
 @param options 可选附加参数，如@{@"center": @"latitude,longitude", @"zoom": @"14"}
 @return NSURL
 */
- (nullable NSURL *)googleMapsURLWithAddr:(nullable NSString *)addr options:(nullable NSDictionary *)options;

/**
 生成谷歌地图导航外部URL，URL SCHEME为：comgooglemaps
 
 @param saddr 导航起始点，格式latitude,longitude或搜索地址
 @param daddr 导航结束点，格式latitude,longitude或搜索地址
 @param mode 导航模式，支持driving|transit|bicycling|walking，默认driving
 @param options 可选附加参数，如@{@"center": @"latitude,longitude", @"zoom": @"14", @"dirflg": @"t,h"}
 @return NSURL
 */
- (nullable NSURL *)googleMapsURLWithSaddr:(nullable NSString *)saddr daddr:(nullable NSString *)daddr mode:(nullable NSString *)mode options:(nullable NSDictionary *)options;

/**
 生成百度地图外部URL，URL SCHEME为：baidumap
 
 @param addr 显示地址，格式latitude,longitude或搜索地址
 @param options 可选附加参数，如@{@"src": @"app", @"zoom": @"14", @"coord_type": @"默认gcj02|wgs84|bd09ll"}
 @return NSURL
 */
- (nullable NSURL *)baiduMapsURLWithAddr:(nullable NSString *)addr options:(nullable NSDictionary *)options;

/**
 生成百度地图导航外部URL，URL SCHEME为：baidumap
 
 @param saddr 导航起始点，格式latitude,longitude或搜索地址
 @param daddr 导航结束点，格式latitude,longitude或搜索地址
 @param mode 导航模式，支持driving|transit|navigation|riding|walking，默认driving
 @param options 可选附加参数，如@{@"src": @"app", @"zoom": @"14", @"coord_type": @"默认gcj02|wgs84|bd09ll"}
 @return NSURL
 */
- (nullable NSURL *)baiduMapsURLWithSaddr:(nullable NSString *)saddr daddr:(nullable NSString *)daddr mode:(nullable NSString *)mode options:(nullable NSDictionary *)options;

@end

NS_ASSUME_NONNULL_END
