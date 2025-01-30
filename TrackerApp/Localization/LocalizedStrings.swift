//
//  LocalizedStrings.swift
//  TrackerApp
//
//  Created by Maksim on 22.01.2025.
//

import Foundation

enum LocalizedStrings {
    
    enum Onboarding {
        static let firstTitle = NSLocalizedString("onboarding.first.title", comment: "Title for the first onboarding screen")
        static let secondTitle = NSLocalizedString("onboarding.second.title", comment: "Title for the second onboarding screen")
        static let buttonText = NSLocalizedString("onboarding.button.text", comment: "Text for the onboarding button")
    }
    
    enum Trackers {
        static let title = NSLocalizedString("trackers.title", comment: "Title for the trackers screen")
        static let placeholderText = NSLocalizedString("trackers.placeholder.text", comment: "Text for the placeholder")
        static let searchPlaceHolder = NSLocalizedString("trackers.searchPlaceHolder", comment: "Search")
        static let filters = NSLocalizedString("trackers.filters", comment: "Filters")
        static let pinned = NSLocalizedString("trackers.pinned", comment: "Pinned")
        static let nothingFound = NSLocalizedString("trackers.nothingFound", comment: "Nothing found")
        
    }
    
    enum Schedule {
        static let title = NSLocalizedString("schedule.title", comment: "Title for the schedule view")
        static let buttonText = NSLocalizedString("schedule.button.text", comment: "Text for the done button in the schedule view")
    }
    
    enum TrackerCreation {
        static let title = NSLocalizedString("tracker_creation.title", comment: "Title for tracker creation view")
        static let habitButton = NSLocalizedString("tracker_creation.button.habit", comment: "Text for the habit creation button")
        static let irregularEventButton = NSLocalizedString("tracker_creation.button.irregular_event", comment: "Text for the irregular event creation button")
    }
    
    enum NewTracker {
        static let habitTitle = NSLocalizedString("new_tracker.event_type.habit", comment: "Title for a new habit tracker")
        static let editTitle = NSLocalizedString("new_tracker.edit.title", comment: "Edit Title")
        static let notRegularEvent = NSLocalizedString("new_tracker.event_type.one_off", comment: "Title for an irregular event tracker")
        static let placeholderName = NSLocalizedString("new_tracker.placeholder.name", comment: "Placeholder for tracker name input field")
        static let cancelButton = NSLocalizedString("new_tracker.button.cancel", comment: "Cancel button text")
        static let createButton = NSLocalizedString("new_tracker.button.create", comment: "Create button text")
        static let categoryTitle = NSLocalizedString("new_tracker.title.category", comment: "Title for category cell")
        static let scheduleTitle = NSLocalizedString("new_tracker.title.schedule", comment: "Title for schedule cell")
        static let colorText = NSLocalizedString("new_tracker.color.text", comment: "Title for color selection collection view")
    }
    
    enum Categories {
        static let title = NSLocalizedString("categories.title", comment: "Title for the categories view")
        static let addButton = NSLocalizedString("categories.button.add", comment: "Add category button text")
        static let placeholderText = NSLocalizedString("categories.placeholder.text", comment: "Placeholder text when no categories are available")
    }
    
    enum NewCategory {
        static let title = NSLocalizedString("new_category.title", comment: "Title for new category view")
        static let placeholder = NSLocalizedString("new_category.placeholder", comment: "Placeholder for category name input field")
        static let doneButton = NSLocalizedString("new_category.button.done", comment: "Text for done button")
    }
    
    enum TabBar {
        static let categories = NSLocalizedString("tabBar.trackers", comment: "Трекеры")
        static let statistics = NSLocalizedString("tabBar.statistics", comment:"Ститистика")
    }
    enum WeekDays {
        static let shortMonday = NSLocalizedString("weekdays.short.monday", comment: "Short form for Monday")
        static let shortTuesday = NSLocalizedString("weekdays.short.tuesday", comment: "Short form for Tuesday")
        static let shortWednesday = NSLocalizedString("weekdays.short.wednesday", comment: "Short form for Wednesday")
        static let shortThursday = NSLocalizedString("weekdays.short.thursday", comment: "Short form for Thursday")
        static let shortFriday = NSLocalizedString("weekdays.short.friday", comment: "Short form for Friday")
        static let shortSaturday = NSLocalizedString("weekdays.short.saturday", comment: "Short form for Saturday")
        static let shortSunday = NSLocalizedString("weekdays.short.sunday", comment: "Short form for Sunday")
    }
    enum Statistics {
        static let title = NSLocalizedString(
            "statistics_Title", comment: "Title for the StatisticViewController")
        static let noDataText = NSLocalizedString(
            "statistics_NoDataText", comment: "Text displayed when there is no data to analyze")
        static let trackersCountAvarage = NSLocalizedString(
            "statistics_TrackersCount", comment: "Label for total trackers count")
        static let trackersCompleted = NSLocalizedString(
            "statistics_TrackersCompleted", comment: "Label for completed trackers count")
        
        static let bestPeriod = NSLocalizedString("statisticsScreen_best_period", comment: "Лучший период")
        static let perfectDays =  NSLocalizedString("statisticsScreen_perfect_days", comment: "Идеальные дни")
    }
}
