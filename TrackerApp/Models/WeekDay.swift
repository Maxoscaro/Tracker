//
//  WeekDay.swift
//  TrackerApp
//
//  Created by Maksim on 22.01.2025.
//

import Foundation

public enum WeekDay: String, Codable, CaseIterable {
    case monday = "monday"
    case tuesday = "tuesday"
    case wednesday = "wednesday"
    case thursday = "thursday"
    case friday = "friday"
    case saturday = "saturday"
    case sunday = "sunday"
    
    var localized: String {
        return NSLocalizedString(self.rawValue, comment: "Weekday name")
    }
    
    var shortName: String {
        switch self {
        case .monday: return LocalizedStrings.WeekDays.shortMonday
        case .tuesday: return LocalizedStrings.WeekDays.shortTuesday
        case .wednesday: return LocalizedStrings.WeekDays.shortWednesday
        case .thursday: return LocalizedStrings.WeekDays.shortThursday
        case .friday: return LocalizedStrings.WeekDays.shortFriday
        case .saturday: return LocalizedStrings.WeekDays.shortSaturday
        case .sunday: return LocalizedStrings.WeekDays.shortSunday
        }
    }
    
    static func fromDate(_ date: Date) -> WeekDay? {
        let calendar = Calendar.current
        let weekDayIndex = calendar.component(.weekday, from: date)
        let firstWeekday = calendar.firstWeekday
        
        let mondayFirstWeekdays: [WeekDay] = [
            .monday,
            .tuesday,
            .wednesday,
            .thursday,
            .friday,
            .saturday,
            .sunday
        ]
        
        let sundayFirstWeekdays: [WeekDay] = [
            .sunday,
            .monday,
            .tuesday,
            .wednesday,
            .thursday,
            .friday,
            .saturday
        ]
        
        let weekdaysArray = firstWeekday == 1 ? sundayFirstWeekdays : mondayFirstWeekdays
        var adjustedIndex = weekDayIndex - firstWeekday
        if adjustedIndex < 0 {
            adjustedIndex += 7
        }
        
        return weekdaysArray[adjustedIndex]
    }
}
