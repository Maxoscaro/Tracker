//
//  TrackerRecord.swift
//  TrackerApp
//
//  Created by Maksim on 07.10.2024.
//

import Foundation

struct TrackerRecord: Codable {
    let trackerId: UUID
    let date: Date
    
    init(trackerId: UUID, date: Date) {
        self.trackerId = trackerId
        self.date = date
    }
}
