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

@implementation FWDateWrapper (FWApplication)

#pragma mark - Convert

- (NSString *)stringSinceDate:(NSDate *)date
{
    double delta = fabs([self.base timeIntervalSinceDate:date]);
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
        return [dateFormatter stringFromDate:self.base];
    } else {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy/MM"];
        return [dateFormatter stringFromDate:self.base];
    }
}

- (NSTimeInterval)timestampValue
{
    return [self.base timeIntervalSince1970];
}

#pragma mark - TimeZone

- (NSDate *)dateWithLocalTimeZone
{
    return [self dateWithTimeZone:[NSTimeZone localTimeZone]];
}

- (NSDate *)dateWithUTCTimeZone
{
    return [self dateWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
}

- (NSDate *)dateWithTimeZone:(NSTimeZone *)timeZone
{
    NSInteger timeOffset = [timeZone secondsFromGMTForDate:self.base];
    NSDate *newDate = [self.base dateByAddingTimeInterval:timeOffset];
    return newDate;
}

#pragma mark - Calendar

- (NSInteger)calendarUnit:(NSCalendarUnit)unit
{
    return [[NSCalendar currentCalendar] component:unit fromDate:self.base];
}

- (BOOL)isLeapYear
{
    NSInteger year = [[NSCalendar currentCalendar] component:NSCalendarUnitYear fromDate:self.base];
    if (year % 400 == 0) {
        return YES;
    } else if (year % 100 == 0) {
        return NO;
    } else if (year % 4 == 0) {
        return YES;
    }
    return NO;
}

- (BOOL)isSameDay:(NSDate *)date
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:date];
    NSDate *dateOne = [[NSCalendar currentCalendar] dateFromComponents:components];
    
    components = [[NSCalendar currentCalendar] components:(NSCalendarUnitEra|NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:self.base];
    NSDate *dateTwo = [[NSCalendar currentCalendar] dateFromComponents:components];
    
    return [dateOne isEqualToDate:dateTwo];
}

- (NSDate *)dateByAdding:(NSDateComponents *)components
{
    return [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:self.base options:0];
}

- (NSInteger)daysFrom:(NSDate *)date
{
    NSDate *earliest = [self.base earlierDate:date];
    NSDate *latest = (earliest == self.base) ? date : self.base;
    NSInteger multipier = (earliest == self.base) ? -1 : 1;
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:earliest toDate:latest options:0];
    return multipier * components.day;
}

- (double)secondsFrom:(NSDate *)date
{
    return [self.base timeIntervalSinceDate:date];
}

@end

@implementation FWDateClassWrapper (FWApplication)

- (NSTimeInterval)systemUptime
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

- (NSTimeInterval)systemBoottime
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

- (NSDate *)dateWithTimestamp:(NSTimeInterval)timestamp
{
    return [[NSDate alloc] initWithTimeIntervalSince1970:timestamp];
}

@end
