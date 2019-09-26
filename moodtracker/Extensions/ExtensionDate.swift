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

// MARK: - Enum Seach Direction
enum SearchDirection {
    case Next
    case Previous
    
    var calendarSearchDirection: Calendar.SearchDirection {
        switch self {
        case .Next:
            return .forward
        case .Previous:
            return .backward
        }
    }
}

// MARK: - Extension Date
extension Date {
    
    // MARK: Type Methods
    static func fromJS(_ from: String) -> Date? {
        return Measurement.dateFormatter.date(from: from)
    }
    
    static func getWeekDaysInEnglish() -> [String] {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_US_POSIX")
        return calendar.weekdaySymbols
    }
    
    // MARK: Instance Methods
    func toJS() -> String {
        return Measurement.dateFormatter.string(from: self)
    }
    
    func next(_ weekday: Weekday, considerToday: Bool = false) -> Date {
        return get(.Next,
                   weekday,
                   considerToday: considerToday)
    }
    
    func previous(_ weekday: Weekday, considerToday: Bool = false) -> Date {
        return get(.Previous,
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
}

