//
//  CoreDataExtension.swift
//  TrackerApp
//
//  Created by Maksim on 27.01.2025.
//

import Foundation

extension TrackerCoreData {
    
    @objc var pinnedOrCategory: String {
        if isPinned {
            return "Закрепленные"
        }
        return category?.title ?? "Без категории"
    }
}

