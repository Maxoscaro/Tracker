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
    let isPinned: Bool
    
    init(id: UUID = UUID(), title: String, color: String, emoji: String, schedule: Set<WeekDay>, isPinned: Bool? = nil) {
        self.id = id
        self.title = title
        self.color = color
        self.emoji = emoji
        self.schedule = schedule
        self.isPinned = isPinned ?? false
    }

static let defaultTracker: Tracker = Tracker(
    title: "Default Title",
    color: "Default Color",
    emoji: "😊",
    schedule: Set<WeekDay>() )
}

