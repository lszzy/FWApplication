/**
 @header     NSDate+FWApplication.h
 @indexgroup FWApplication
      NSDate+FWApplication
 @author     wuyong
 @copyright  Copyright © 2018年 wuyong.site. All rights reserved.
 @updated    2018/9/17
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 NSDate+FWApplication
 @note NSDate默认GMT时区；NSTimeZone默认系统时区(可设置应用默认时区)；NSDateFormatter默认当前时区(可自定义)，格式化时自动修正NSDate时区(无需手工修正NSDate)；NSLocale默认当前语言环境
 */
@interface NSDate (FWApplication)

#pragma mark - System

/// 系统运行时间
@property (class, nonatomic, assign, readonly) NSTimeInterval fwSystemUptime;

/// 系统启动时间
@property (class, nonatomic, assign, readonly) NSTimeInterval fwSystemBoottime;

#pragma mark - Convert

/**
 *  从时间戳初始化日期
 *
 *  @param timestamp 时间戳
 *
 *  @return NSDate
 */
+ (NSDate *)fwDateWithTimestamp:(NSTimeInterval)timestamp;

/**
 *  计算两个时间差，并格式化为友好的时间字符串(类似微博)
 *  <10分钟：刚刚 <60分钟：n分钟前 <24小时：n小时前 <7天：n天前 <365天：n月/n日 >=365天：n年/n月
 *
 *  @return 字符串
 */
- (NSString *)fwStringSinceDate:(NSDate *)date;

/**
 *  转化为UTC时间戳
 *
 *  @return UTC时间戳
 */
@property (nonatomic, assign, readonly) NSTimeInterval fwTimestampValue;

#pragma mark - TimeZone

// 转换为当前时区时间
@property (nonatomic, strong, readonly) NSDate *fwDateWithLocalTimeZone;

// 转换为UTC时区时间
@property (nonatomic, strong, readonly) NSDate *fwDateWithUTCTimeZone;

// 转换为指定时区时间
- (NSDate *)fwDateWithTimeZone:(nullable NSTimeZone *)timeZone;

#pragma mark - Calendar

// 获取日历单元值，如年、月、日等
- (NSInteger)fwCalendarUnit:(NSCalendarUnit)unit;

// 是否是闰年
@property (nonatomic, assign, readonly) BOOL fwIsLeapYear;

// 是否是同一天
- (BOOL)fwIsSameDay:(NSDate *)date;

// 添加指定日期，如year:1|month:-1|day:1等
- (nullable NSDate *)fwDateByAdding:(NSDateComponents *)components;

// 与指定日期相隔天数
- (NSInteger)fwDaysFrom:(NSDate *)date;

// 与指定日期相隔秒数。分钟数/60，小时数/3600
- (double)fwSecondsFrom:(NSDate *)date;

@end

NS_ASSUME_NONNULL_END
