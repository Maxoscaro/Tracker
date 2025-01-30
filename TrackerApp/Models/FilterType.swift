//
//  FilterType.swift
//  TrackerApp
//
//  Created by Maksim on 26.01.2025.
//

import Foundation

public enum FilterType: String {
    case allTrackers = "allTrackers"
    case todayTrackers = "todayTrackers"
    case completedTrackers = "completedTrackers"
    case uncompletedTrackers = "uncompletedTrackers"
}

public class FilterStore {
    static var selectedFilter: FilterType {
        get {
            if let savedValue = UserDefaults.standard.string(forKey: "selectedFilter") {
                return FilterType(rawValue: savedValue) ?? .todayTrackers
            } else {
                return .todayTrackers
            }
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "selectedFilter")
        }
    }
}
