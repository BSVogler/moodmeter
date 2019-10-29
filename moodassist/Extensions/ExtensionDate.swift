//
//  ExtensionDate.swift
//  moodtracker
//
//  Created by Lukas Gerhardt on 25.09.19.
//  Copyright © 2019 bsvogler. All rights reserved.
//

// MARK: Imports
import Foundation

// MARK: - Enum Weekday
enum Weekday: String {
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday
}

// MARK: - Enum SearchDirection
enum SearchDirection {
    case next
    case previous
    
    var calendarSearchDirection: Calendar.SearchDirection {
        switch self {
        case .next:
            return .forward
        case .previous:
            return .backward
        }
    }
}

// MARK: - Extension Date
extension Date {
    
    // MARK: Type Methods
    static func fromJS(_ from: String) -> Date? {
        return Measurement.jsDateFormatter.date(from: from)
    }
    
    static func getWeekDaysInEnglish() -> [String] {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_US_POSIX")
        return calendar.weekdaySymbols
    }
	
	static func today() -> Date  {
		return Date().normalized()
	}
	
	static func yesterday() -> Date {
		let calendar = Calendar.current
		return calendar.date(byAdding: .day, value: -1, to: Date())!.normalized()
	}
    
    // MARK: Instance Methods
    func toJS() -> String {
        return Measurement.jsDateFormatter.string(from: self)
    }
    
    func next(_ weekday: Weekday, considerToday: Bool = false) -> Date {
        return get(.next,
                   weekday,
                   considerToday: considerToday)
    }
    
    func previous(_ weekday: Weekday, considerToday: Bool = false) -> Date {
        return get(.previous,
                   weekday,
                   considerToday: considerToday)
    }
    
    func get(_ direction: SearchDirection,
             _ weekDay: Weekday,
             considerToday consider: Bool = false) -> Date {
        
        let dayName = weekDay.rawValue
        
        let weekdaysName = Date.getWeekDaysInEnglish().map { $0.lowercased() }
        
        assert(weekdaysName.contains(dayName), "weekday symbol should be in form \(weekdaysName)")
        
        let searchWeekdayIndex = weekdaysName.firstIndex(of: dayName)! + 1
        
        let calendar = Calendar(identifier: .gregorian)
        
        if consider && calendar.component(.weekday, from: self) == searchWeekdayIndex {
            return self
        }
        
        var nextDateComponent = DateComponents()
        nextDateComponent.weekday = searchWeekdayIndex
        
        
        let date = calendar.nextDate(after: self,
                                     matching: nextDateComponent,
                                     matchingPolicy: .nextTime,
                                     direction: direction.calendarSearchDirection)
        
        return date!
    }
	
	
	func normalized() -> Date{
		let calendar = Calendar.current
		return calendar.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
	}
	
}

