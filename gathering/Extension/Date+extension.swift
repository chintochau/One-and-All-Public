//
//  Date+extension.swift
//  Gather Pool
//
//  Created by Jason Chau on 2023-02-25.
//

import UIKit
import SwiftDate

extension Date{
    func startOfDayTimestampUTC() -> TimeInterval {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let startOfDayUTC = calendar.startOfDay(for: self)
        return startOfDayUTC.timeIntervalSince1970
    }

    func startOfWeekTimestampUTC() -> TimeInterval {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let startOfWeekUTC = calendar.startOfDay(for: self.addingTimeInterval(TimeInterval(-calendar.component(.weekday, from: date) * 86400)))
        return startOfWeekUTC.timeIntervalSince1970
    }

    func startOfMonthTimestampUTC() -> TimeInterval {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let year = calendar.component(.year, from: self)
        let month = calendar.component(.month, from: self)
        let startOfMonthUTC = calendar.date(from: DateComponents(year: year, month: month, day: 1))!
        return startOfMonthUTC.timeIntervalSince1970
    }
    
    func startOfNextMonthTimestampUTC() -> TimeInterval {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        var components = calendar.dateComponents([.year, .month], from: self)
        components.month! += 1
        components.day = 1
        let startOfNextMonthUTC = calendar.date(from: components)!
        return startOfNextMonthUTC.startOfMonthTimestampUTC()
    }


    func monthOfYearUTC() -> Int {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar.component(.month, from: self)
    }

    func dayOfYearUTC() -> Int {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar.ordinality(of: .day, in: .year, for: self)!
    }

    func weekOfYearUTC() -> Int {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar.component(.weekOfYear, from: self)
    }

    func yearMonthStringUTC() -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let year = calendar.component(.year, from: date)
        let month = String(format: "%02d", calendar.component(.month, from: self))
        return "\(year)\(month)"
    }

    func yearDayStringUTC() -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let year = calendar.component(.year, from: date)
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: self)!
        return "\(year)\(dayOfYear)"
    }

    func yearWeekStringUTC() -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let year = calendar.component(.year, from: date)
        let weekOfYear = String(format: "%02d", calendar.component(.weekOfYear, from: self))
        return "\(year)\(weekOfYear)"
    }

}
extension TimeInterval {
    func toDate() -> Date {
        return Date(timeIntervalSince1970: self)
    }
}

extension Date {
    
    
    /// return String in format yyyyMM, i.e. 202312
    /// Used for User event reference
    func yearMonthStringLocalTime () -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMM"
        return dateFormatter.string(from: self)
    }
    
    
    /// used for ref: "events/{YearWeek}"
    func yearWeekStringLocalTime() -> String {
        let calendar = Calendar.current
        let weekOfYear = calendar.component(.weekOfYear, from: self)
        let year = calendar.component(.year, from: self)
        return String(format: "%04d%02d", year, weekOfYear)
    }
    
    
    func firstDayOfWeekTimestamp() -> Double {
        return startOfWeekLocalTime().timeIntervalSince1970
    }
    
    func lastDayOfWeekTimestamp() -> Double {
        let calendar = Calendar.current
        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))!
        return weekStart.adding(days: 7).timeIntervalSince1970
    }
    
    func startOfWeekLocalTime() -> Date{
        let calendar = Calendar.current
        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))!
        return weekStart
    }
    
    
    func startOfTheSameMonthLocalTime () -> Date {
        let calendar = Calendar.current // The calendar to use for the conversion
        let components = calendar.dateComponents([.year, .month], from: self) // Extract the year and month components of the date
        return calendar.date(from: components)! // Create a new date using the year and month components
    }
    
    func startOfTheNextMonthLocalTime() -> Date {
        let calendar = Calendar.current
        let nextMonth = calendar.date(byAdding: .month, value: 1, to: self)!
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: nextMonth))!
        return startOfMonth
    }
    
    
    static func startOfTodayLocalTime() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd 00:00:00"
        let dateString = dateFormatter.string(from: Date())
        let todayAtMidnight = dateFormatter.date(from: dateString)
        
        return todayAtMidnight!
    }
    
    static func startOfTomorrowLocalTime() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd 00:00:00"
        let currentDate = Date()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
        let dateString = dateFormatter.string(from: tomorrow)
        let tomorrowAtMidnight = dateFormatter.date(from: dateString)
        return tomorrowAtMidnight!
    }
    
    static func startOfThisWeekLocalTime() -> Date {
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: calendar.startOfDay(for: Date())))!
        return startOfWeek
    }
    
    static func startOfNextWeekLocalTime() -> Date {
        let calendar = Calendar.current
        let startOfNextWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: startOfThisWeekLocalTime())!
        return startOfNextWeek
    }
    
    static func startOfTwoWeeksAfterLocalTime() -> Date {
        let calendar = Calendar.current
        let startOfTwoWeeksAfter = calendar.date(byAdding: .weekOfYear, value: 2, to: startOfThisWeekLocalTime())!
        return startOfTwoWeeksAfter
    }
    
    
    
    
    func adding(days: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: days, to: self)!
    }
    
    func subtract(days: Int) -> Date {
        let secondsInDay: TimeInterval = Double(days) * 86400
        return self.addingTimeInterval(-secondsInDay)
    }
    
    
    
    
}


extension String {
    
    static func date(from date: Date) -> String? {
        let formatter = DateFormatter.formatter
        let string = formatter.string(from: date)
        return string
    }
    
    static func localeDate(from date:String,_ identifier: LocaleIdentifier) -> (date:String,dayOfWeek:String,time:String,relative:String) {
        let formatter = DateFormatter.formatter
        guard let date = formatter.date(from: date) else {return ("nil","nil","nil","nil")}
        
        let fullDateString = localeDate(from: date, identifier)
        
        return (fullDateString.date,fullDateString.dayOfWeek,fullDateString.time,fullDateString.relative)
    }
    
    static func localeDate(from date:Date,_ identifier: LocaleIdentifier) -> (date:String,dayOfWeek:String,time:String,relative:String) {
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: identifier.rawValue)
        
        
        
        let dateInDeviceLocalTime = DateInRegion(date,region: .current)
        
        // Date
        let dateString = dateInDeviceLocalTime.toFormat("M月d日")
        
        // Day of the week
        let dayString = dateInDeviceLocalTime.weekdayName(.short)
        
        // Time
        let timeString = dateInDeviceLocalTime.toFormat("h:mma")
        
        
        // Relative
        let relativeString = dateInDeviceLocalTime.toRelative(locale:Locales.chineseTraditional).replacingOccurrences(of: "时", with: "時")
        
        
        return (dateString,dayString,timeString,relativeString)
    }
    
    
}

extension String {
    static func getDateStringForCell(startDate:Date, endDate:Date) -> String {
        
            // MARK: - Date
            var finalDateString:String = ""
            var startString:String = ""
            var endString:String = ""
            let startDateString = String.localeDate(from: startDate, .zhHantTW)
            let endDateString = String.localeDate(from: endDate, .zhHantTW)
            
            
            switch startDate {
            case ..<Date.startOfTodayLocalTime():
                startString = startDateString.relative
            case ..<Date.startOfTomorrowLocalTime():
                startString = "今天"
            case ..<Date.startOfTomorrowLocalTime().adding(days: 1):
                startString = "明天"
            default:
                startString = startDateString.date
            }
            
            switch endDate {
            case ..<Date.startOfTodayLocalTime():
                endString = endDateString.relative
            case ..<Date.startOfTomorrowLocalTime():
                endString = "今天"
            case ..<Date.startOfTomorrowLocalTime().adding(days: 1):
                endString = "明天"
            default:
                endString = endDateString.date
            }
            
            if startDateString == endDateString {
                // Same Day same time
                finalDateString = "\(startDateString.dayOfWeek),\(startString) \(startDateString.time)"
                
            }else if startDateString.date == endDateString.date {
                // same day different time
                finalDateString = "\(startDateString.dayOfWeek),\(startString) \(startDateString.time) - \(endDateString.time)"
                
            }else {
                
                finalDateString = "\(startDateString.dayOfWeek),\(startString) - \(endDateString.dayOfWeek),\(endString)"
            }
            
            return finalDateString
    }
}
