/**
 @header     NSDate+FWApplication.m
 @indexgroup FWApplication
      NSDate+FWApplication
 @author     wuyong
 @copyright  Copyright © 2018年 wuyong.site. All rights reserved.
 @updated    2018/9/17
 */

#import "NSDate+FWApplication.h"
#import <sys/sysctl.h>

@implementation NSDate (FWApplication)

#pragma mark - System

+ (NSTimeInterval)fwSystemUptime
{
    struct timeval bootTime;
    int mib[2] = {CTL_KERN, KERN_BOOTTIME};
    size_t size = sizeof(bootTime);
    int resctl = sysctl(mib, 2, &bootTime, &size, NULL, 0);

    struct timeval now;
    struct timezone tz;
    gettimeofday(&now, &tz);
    
    NSTimeInterval uptime = 0;
    if (resctl != -1 && bootTime.tv_sec != 0) {
        uptime = now.tv_sec - bootTime.tv_sec;
        uptime += (now.tv_usec - bootTime.tv_usec) / 1.e6;
    }
    return uptime;
}

+ (NSTimeInterval)fwSystemBoottime
{
    struct timeval bootTime;
    int mib[2] = {CTL_KERN, KERN_BOOTTIME};
    size_t size = sizeof(bootTime);
    int resctl = sysctl(mib, 2, &bootTime, &size, NULL, 0);
    
    if (resctl != -1 && bootTime.tv_sec != 0) {
        return bootTime.tv_sec + bootTime.tv_usec / 1.e6;
    }
    return 0;
}

#pragma mark - Convert

+ (NSDate *)fwDateWithTimestamp:(NSTimeInterval)timestamp
{
    return [[NSDate alloc] initWithTimeIntervalSince1970:timestamp];
}

- (NSString *)fwStringSinceDate:(NSDate *)date
{
    double delta = fabs([self timeIntervalSinceDate:date]);
    if (delta < 10 * 60) {
        return @"刚刚";
    } else if (delta < 60 * 60) {
        int minutes = floor((double)delta / 60);
        return [NSString stringWithFormat:@"%d分钟前", minutes];
    } else if (delta < 24 * 3600) {
        int hours = floor((double)delta / 3600);
        return [NSString stringWithFormat:@"%d小时前", hours];
    } else if (delta < 7 * 86400) {
        int days = floor((double)delta / 86400);
        return [NSString stringWithFormat:@"%d天前", days];
    } else if (delta < 365 * 86400) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM/dd"];
        return [dateFormatter stringFromDate:self];
    } else {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy/MM"];
        return [dateFormatter stringFromDate:self];
    }
}

- (NSTimeInterval)fwTimestampValue
{
    return [self timeIntervalSince1970];
}

#pragma mark - TimeZone

- (NSDate *)fwDateWithLocalTimeZone
{
    return [self fwDateWithTimeZone:[NSTimeZone localTimeZone]];
}

- (NSDate *)fwDateWithUTCTimeZone
{
    return [self fwDateWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
}

- (NSDate *)fwDateWithTimeZone:(NSTimeZone *)timeZone
{
    NSInteger timeOffset = [timeZone secondsFromGMTForDate:self];
    NSDate *newDate = [self dateByAddingTimeInterval:timeOffset];
    return newDate;
}

#pragma mark - Calendar

- (NSInteger)fwCalendarUnit:(NSCalendarUnit)unit
{
    return [[NSCalendar currentCalendar] component:unit fromDate:self];
}

- (BOOL)fwIsLeapYear
{
    NSInteger year = [[NSCalendar currentCalendar] component:NSCalendarUnitYear fromDate:self];
    if (year % 400 == 0) {
        return YES;
    } else if (year % 100 == 0) {
        return NO;
    } else if (year % 4 == 0) {
        return YES;
    }
    return NO;
}

- (BOOL)fwIsSameDay:(NSDate *)date
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:date];
    NSDate *dateOne = [[NSCalendar currentCalendar] dateFromComponents:components];
    
    components = [[NSCalendar currentCalendar] components:(NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:self];
    NSDate *dateTwo = [[NSCalendar currentCalendar] dateFromComponents:components];
    
    return [dateOne isEqualToDate:dateTwo];
}

- (NSDate *)fwDateByAdding:(NSDateComponents *)components
{
    return [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:self options:0];
}

- (NSInteger)fwDaysFrom:(NSDate *)date
{
    NSDate *earliest = [self earlierDate:date];
    NSDate *latest = (earliest == self) ? date : self;
    NSInteger multipier = (earliest == self) ? -1 : 1;
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:earliest toDate:latest options:0];
    return multipier * components.day;
}

- (double)fwSecondsFrom:(NSDate *)date
{
    return [self timeIntervalSinceDate:date];
}

#pragma mark - Format

+ (NSTimeInterval)fwFormatTimestamp:(NSTimeInterval)timestamp
{
    NSString *timestampStr = [NSString stringWithFormat:@"%ld", (long)timestamp];
    if (timestampStr.length == 16) {
        return timestamp / 1000.f / 1000.f;
    } else if (timestampStr.length == 13) {
        return timestamp / 1000.f;
    } else {
        return timestamp;
    }
}

@end
