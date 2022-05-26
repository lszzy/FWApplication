/**
 @header     NSBundle+FWApplication.h
 @indexgroup FWApplication
 @author     wuyong
 @copyright  Copyright © 2018年 wuyong.site. All rights reserved.
 @updated    2018-09-17
 */

@import FWFramework;

NS_ASSUME_NONNULL_BEGIN

@interface FWBundleClassWrapper (FWApplication)

// 自定义GoogleMaps反解析地址结果语言，为nil时不指定
- (void)setGoogleMapsLanguage:(nullable NSString *)language;

// 自定义GooglePlaces查询地址结果语言，为nil时不指定
- (void)setGooglePlacesLanguage:(nullable NSString *)language;

@end

NS_ASSUME_NONNULL_END
