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

