//
//  TrackerCategory.swift
//  TrackerApp
//
//  Created by Maksim on 07.10.2024.
//

import Foundation

struct TrackerCategory {
    let title: String
    let trackers: [Tracker]
    
    init(title: String, trackers: [Tracker]) {
        self.title = title
        self.trackers = trackers
    }
}
