//
//  DataClass.swift
//  Yogogo
//
//  Created by prince on 2020/12/8.
//

import UIKit

class DateClass {
    
    // MARK: - 時間與時間戳之間的轉化
    
    // 將時間轉換為時間戳
    static func stringToTimeStamp(_ stringTime: String) -> Int {
        let dfmatter = DateFormatter()
        dfmatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dfmatter.locale = Locale.current
        let date = dfmatter.date(from: stringTime)
        let dateStamp: TimeInterval = date!.timeIntervalSince1970
        let dateSt: Int = Int(dateStamp)
        return dateSt
    }
    
    // 將時間戳轉換為年月日
    static func timeStampToString(_ timeStamp: String) -> String {
        let string = NSString(string: timeStamp)
        let timeSta: TimeInterval = string.doubleValue
        let dfmatter = DateFormatter()
        dfmatter.dateFormat = "yyyy-MM-dd"
        let date = Date(timeIntervalSince1970: timeSta)
        return dfmatter.string(from: date)
    }
    
    // MARK: - 將時間戳轉換為具體時間
    static func timeStampToStringDetail(_ timeStamp: String) -> String {
        let string = NSString(string: timeStamp)
        let timeSta: TimeInterval = string.doubleValue
        let dfmatter = DateFormatter()
        dfmatter.dateFormat = "yyyy年 MM月 dd日 HH:mm:ss"
        let date = Date(timeIntervalSince1970: timeSta)
        return dfmatter.string(from: date)
    }
    
    // MARK: - timeStampToDate
    static func timeStampToDate(_ timeStamp: String) -> Date {
        let string = NSString(string: timeStamp)
        let timeSta: TimeInterval = string.doubleValue
        let dfmatter = DateFormatter()
        dfmatter.dateFormat = "yyyy年 MM月 dd日 HH:mm:ss"
        return Date(timeIntervalSince1970: timeSta)
    }
    
    // 將時間戳轉換為時分秒
    static func timeStampToHHMMSS(_ timeStamp: String) -> String {
        let string = NSString(string: timeStamp)
        let timeSta: TimeInterval = string.doubleValue
        let dfmatter = DateFormatter()
        dfmatter.dateFormat="HH:mm:ss"
        let date = Date(timeIntervalSince1970: timeSta)
        return dfmatter.string(from: date)
    }
    
    // 獲取系統的當前時間戳
    static func getStamp() -> Int {
        // 獲取當前時間戳
        let date = Date()
        let timeInterval: Int = Int(date.timeIntervalSince1970)
        return timeInterval
    }
    
    // 月份數字轉漢字
    //        static func numberToChina(monthNum:Int) -> String {
    //
    //            let ChinaArray = ["一月","二月","三月","四月","五月","六月","七月","八月","九月","十月","十一月","十二月"]
    //
    //            let ChinaStr:String = ChinaArray[monthNum - 1]
    //            return ChinaStr
    //
    //        }
    // MARK: 數字前補0
    static func add0BeforeNumber(_ number: Int) -> String {
        
        if number >= 10 {
            return String(number)
            
        } else {
            return "0" + String(number)
        }
    }
    
    // MARK: - 將時間顯示為（幾分鐘前，幾小時前，幾天前）
    static func compareCurrentTime(str: String) -> String {
        
//        let timeDate = self.timeStringToDate(str)
        let timeDate = self.timeStampToDate(str)
        
        let currentDate = NSDate()
        
        let timeInterval = currentDate.timeIntervalSince(timeDate)
        
        var temp: Double = 0
        
        var result: String = ""
        
        if timeInterval / 60 < 1 {
            
            result = "Now"
            
        } else if (timeInterval / 60) < 60 {
            
            temp = timeInterval / 60
            
            result = "\(Int(temp))m ago"
            
        } else if timeInterval / 60 / 60 < 24 {
            
            temp = timeInterval / 60 / 60
            
            result = "\(Int(temp))h ago"
            
        } else if timeInterval / (24 * 60 * 60) < 30 {
            
            temp = timeInterval / (24 * 60 * 60)
            
            result = "\(Int(temp))d ago"
            
        } else if timeInterval / (30 * 24 * 60 * 60)  < 12 {
            
//            temp = timeInterval / (30 * 24 * 60 * 60)
//
//            result = "\(Int(temp))M ago"
            
            result = timeStampToString(str)
            
        } else {
            
//            temp = timeInterval / (12 * 30 * 24 * 60 * 60)
//
//            result = "\(Int(temp))y ago"
            
            result = timeStampToString(str)
        }
        
        return result
    }
}

extension DateClass {
    
    // MARK: - 當前時間相關
    
    // MARK: 今年
    static func currentYear() -> Int {
        let calendar = NSCalendar.current
        let com = calendar.dateComponents([.year, .month, .day], from: Date())
        return com.year!
    }
    // MARK: 今月
    static func currentMonth() -> Int {
        let calendar = NSCalendar.current
        let com = calendar.dateComponents([.year, .month, .day], from: Date())
        return com.month!
        
    }
    // MARK: 今日
    static func currentDay() -> Int {
        let calendar = NSCalendar.current
        let com = calendar.dateComponents([.year, .month, .day], from: Date())
        return com.day!
        
    }
    // MARK: 今天星期幾
    static func currentWeekDay() -> Int {
        let interval = Int(Date().timeIntervalSince1970)
        let days = Int(interval/86400) // 24*60*60
        let weekday = ((days + 4) % 7 + 7 ) % 7
        return weekday == 0 ? 7 : weekday
    }
    // MARK: 本月天數
    static func countOfDaysInCurrentMonth() -> Int {
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let range = (calendar as NSCalendar?)?.range(of: NSCalendar.Unit.day, in: NSCalendar.Unit.month, for: Date())
        return (range?.length)!
        
    }
    // MARK: 當月第一天是星期幾
    //        static func firstWeekDayInCurrentMonth() ->Int {
    //            //星期和數字一一對應 星期日：7
    //            let dateFormatter = DateFormatter()
    //            dateFormatter.dateFormat = "yyyy-MM"
    //            let date = dateFormatter.date(from: String(Date().year()) + "-" + String(Date().month()))
    //            let calender = Calendar(identifier:Calendar.Identifier.gregorian)
    //            let comps = (calender as NSCalendar?)?.components(NSCalendar.Unit.weekday, from: date!)
    //            var week = comps?.weekday
    //            if week == 1 {
    //                week = 8
    //            }
    //            return week! - 1
    //        }
    // MARK: - 獲取指定日期各種值
    // 根據年月得到某月天數
    static func getCountOfDaysInMonth(year: Int, month: Int) -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM"
        let date
            = dateFormatter.date(from: String(year)+"-"+String(month))
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let range = (calendar as NSCalendar?)?.range(of: NSCalendar.Unit.day, in: NSCalendar.Unit.month, for: date!)
        return (range?.length)!
    }
    // MARK: 根據年月得到某月第一天是周幾
    static func getfirstWeekDayInMonth(year: Int, month: Int) -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM"
        let date
            = dateFormatter.date(from: String(year)+"-"+String(month))
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let comps = (calendar as NSCalendar?)?.components(NSCalendar.Unit.weekday, from: date!)
        let week = comps?.weekday
        return week! - 1
    }
    
    // MARK: date轉日期字串
    static func dateToDateString(_ date: Date, dateFormat: String) -> String {
        let timeZone = NSTimeZone.local
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.dateFormat = dateFormat
        
        let date = formatter.string(from: date)
        return date
    }
    
    // MARK: 日期字串轉date
    static func dateStringToDate(_ dateStr: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date
            = dateFormatter.date(from: dateStr)
        return date!
    }
    // MARK: 時間字串轉date
//    static func timeStringToDate(_ dateStr: String) -> Date {
//        let dateFormatter = DateFormatter()
//        //        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
//        dateFormatter.dateFormat = "yyyy-MM-dd  HH:mm:ss"
//        let date
//            = dateFormatter.date(from: dateStr)
//        return date!
//    }
    
    // MARK: 計算天數差
    static func dateDifference(_ dateA: Date, from dateB: Date) -> Double {
        let interval = dateA.timeIntervalSince(dateB)
        return interval/86400
        
    }
    
    // MARK: 比較時間先後
    static func compareOneDay(oneDay: Date, withAnotherDay anotherDay: Date) -> Int {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let oneDayStr: String = dateFormatter.string(from: oneDay)
        let anotherDayStr: String = dateFormatter.string(from: anotherDay)
        let dateA = dateFormatter.date(from: oneDayStr)
        let dateB = dateFormatter.date(from: anotherDayStr)
        let result: ComparisonResult = (dateA?.compare(dateB!))!
        //Date1  is in the future
        if result == ComparisonResult.orderedDescending {
            return 1
            
        }
        //Date1 is in the past
        else if result == ComparisonResult.orderedAscending {
            return 2
            
        }
        //Both dates are the same
        else {
            return 0
        }
    }
}
