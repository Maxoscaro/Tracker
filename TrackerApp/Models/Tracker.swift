//
//  Tracker.swift
//  TrackerApp
//
//  Created by Maksim on 07.10.2024.
//

import UIKit

struct Tracker: Identifiable, Equatable, Codable {
    let id: UUID
    let title: String
    let color: String
    let emoji: String
    let schedule: Set<WeekDay>
    
    init(id: UUID, title: String, color: String, emoji: String, schedule: Set<WeekDay>) {
        self.id = id
        self.title = title
        self.color = color
        self.emoji = emoji
        self.schedule = schedule
    }
}

enum WeekDay: String, Codable, CaseIterable {
    case monday = "Понедельник"
    case tuesday = "Вторник"
    case wednesday = "Среда"
    case thursday = "Четверг"
    case friday = "Пятница"
    case saturday = "Суббота"
    case sunday = "Воскресенье"
    
    static func fromDate(_ date: Date) -> WeekDay? {
        let calendar = Calendar.current
        let weekDayIndex = calendar.component(.weekday, from: date)
        
        let weekDays = [
            WeekDay.sunday,
            WeekDay.monday,
            WeekDay.tuesday,
            WeekDay.wednesday,
            WeekDay.thursday,
            WeekDay.friday,
            WeekDay.saturday
        ]
        return weekDays[weekDayIndex - 1]
    }
}
