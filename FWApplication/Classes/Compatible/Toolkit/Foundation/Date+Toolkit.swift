//
//  Date+Toolkit.swift
//  FWApplication
//
//  Created by wuyong on 2022/5/19.
//

import Foundation

/// NSDate默认GMT时区；NSTimeZone默认系统时区(可设置应用默认时区)；NSDateFormatter默认当前时区(可自定义)，格式化时自动修正NSDate时区(无需手工修正NSDate)；NSLocale默认当前语言环境
extension Wrapper where Base == Date {
    
    // MARK: - Convert

    /**
     *  计算两个时间差，并格式化为友好的时间字符串(类似微博)
     *  <10分钟：刚刚 <60分钟：n分钟前 <24小时：n小时前 <7天：n天前 <365天：n月/n日 >=365天：n年/n月
     *
     *  @return 字符串
     */
    public func string(sinceDate: Date) -> String {
        return (base as NSDate).__fw.string(since: sinceDate)
    }

    /**
     *  转化为UTC时间戳
     *
     *  @return UTC时间戳
     */
    public var timestampValue: TimeInterval {
        return (base as NSDate).__fw.timestampValue
    }

    // MARK: - TimeZone

    /// 转换为当前时区时间
    public var localTimeZoneDate: Date {
        return (base as NSDate).__fw.dateWithLocalTimeZone
    }

    /// 转换为UTC时区时间
    public var utcTimeZoneDate: Date {
        return (base as NSDate).__fw.dateWithUTCTimeZone
    }

    /// 转换为指定时区时间
    public func date(timeZone: TimeZone?) -> Date {
        return (base as NSDate).__fw.date(with: timeZone)
    }

    // MARK: - Calendar

    /// 获取日历单元值，如年、月、日等
    public func calendarUnit(_ unit: NSCalendar.Unit) -> Int {
        return (base as NSDate).__fw.calendarUnit(unit)
    }

    /// 是否是闰年
    public var isLeapYear: Bool {
        return (base as NSDate).__fw.isLeapYear
    }

    /// 是否是同一天
    public func isSameDay(_ date: Date) -> Bool {
        return (base as NSDate).__fw.isSameDay(date)
    }

    /// 添加指定日期，如year:1|month:-1|day:1等
    public func date(byAdding: DateComponents) -> Date? {
        return (base as NSDate).__fw.date(byAdding: byAdding)
    }

    /// 与指定日期相隔天数
    public func days(from date: Date) -> Int {
        return (base as NSDate).__fw.days(from: date)
    }

    /// 与指定日期相隔秒数。分钟数/60，小时数/3600
    public func seconds(from date: Date) -> TimeInterval {
        return (base as NSDate).__fw.seconds(from: date)
    }
    
    /// 系统运行时间
    public static var systemUptime: TimeInterval {
        return NSDate.__fw.systemUptime
    }

    /// 系统启动时间
    public static var systemBoottime: TimeInterval {
        return NSDate.__fw.systemBoottime
    }

    /// 从时间戳初始化日期
    public static func date(timestamp: TimeInterval) -> Date {
        return NSDate.__fw.date(withTimestamp: timestamp)
    }
    
}
