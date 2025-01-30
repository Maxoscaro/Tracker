//
//  StatisticsStore.swift
//  TrackerApp
//
//  Created by Maksim on 28.01.2025.
//

import UIKit
import CoreData

final class StatisticsStore {
    
    static var shared = StatisticsStore()
    
    var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>?
    
    public var perfectDaysCount: Int {
        get {
            return UserDefaults.standard.integer(forKey: "StatisticsScreen.perfectDaysCount")
        }
        set {
            let currentStoredValue = UserDefaults.standard.integer(forKey: "StatisticsScreen.perfectDaysCount")
            if newValue > currentStoredValue {
                UserDefaults.standard.set(newValue, forKey: "StatisticsScreen.perfectDaysCount")
            }
        }
    }

    public var trackersCompleteCount: Int {
        get {
            return UserDefaults.standard.integer(forKey: "StatisticsScreen.trackersCompleteCount")
        }
        set {
            let currentStoredValue = UserDefaults.standard.integer(forKey: "StatisticsScreen.trackersCompleteCount")
            if newValue > currentStoredValue {
                UserDefaults.standard.set(newValue, forKey: "StatisticsScreen.trackersCompleteCount")
            }
        }
    }

    public var averageCount: Int {
        get {
            return UserDefaults.standard.integer(forKey: "StatisticsScreen.averageCount")
        }
        set {
            let currentStoredValue = UserDefaults.standard.integer(forKey: "StatisticsScreen.averageCount")
            if newValue > currentStoredValue {
                UserDefaults.standard.set(newValue, forKey: "StatisticsScreen.averageCount")
            }
        }
    }

    public var bestPeriodCount: Int {
        get {
            return UserDefaults.standard.integer(forKey: "StatisticsScreen.bestPeriodCount")
        }
        set {
            let currentStoredValue = UserDefaults.standard.integer(forKey: "StatisticsScreen.bestPeriodCount")
            if newValue > currentStoredValue {
                UserDefaults.standard.set(newValue, forKey: "StatisticsScreen.bestPeriodCount")
            }
        }
    }
    
    private var appDelegate: AppDelegate {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("UIApplication.shared.delegate is not of type AppDelegate")
        }
        return delegate
    }
    
    private var context: NSManagedObjectContext {
        appDelegate.persistentContainer.viewContext
    }
    
    //MARK: - Настраиваем FRC
    
    func setupFetchedResultsController(_ predicate: NSPredicate, with trackerTitlePredicate: NSPredicate? = nil) {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "isPinned", ascending: false),
            NSSortDescriptor(key: "category.title", ascending: true),
            NSSortDescriptor(key: "title", ascending: true)
        ]
        
        fetchRequest.predicate = predicate
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: "pinnedOrCategory",
            cacheName: nil
        )
        
        guard let fetchedResultsController else { return }
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Failed to fetch data: \(error)")
        }
    }
    
    //MARK: - Завершенные трекеры
    
    public func fetchAllRecordsCount() -> Int {
        let allRecordsPredicate = NSPredicate(format: "record.@count > 0")
        
        self.setupFetchedResultsController(allRecordsPredicate)
        
        guard let fetchedObjects = fetchedResultsController?.fetchedObjects else {
            print("No fetched objects found")
            return 0
        }
        
        var totalRecordsCount = 0
        for trackerEntity in fetchedObjects {
            if let records = trackerEntity.record?.count {
                totalRecordsCount += records
            } else {
                print("No records found for tracker entity: \(trackerEntity)")
            }
        }
        
        return totalRecordsCount
    }
    
    //MARK: - Идеальные дни
    
    public func fetchPerfectDaysCount(from earliestDate: Date, trackerStore: TrackerStore) -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        var dates: [Date] = []
        var currentDate = calendar.startOfDay(for: earliestDate)
        
        while currentDate <= today {
            dates.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        let scheduledDates = dates.filter { date in
            guard let selectedWeekday = WeekDay.fromDate(date) else { return false }
            let predicate = NSPredicate(format: "schedule CONTAINS[cd] %@", selectedWeekday.rawValue)
            self.setupFetchedResultsController(predicate)
            
            let hasScheduledTrackers = fetchedResultsController?.fetchedObjects?.isEmpty == false
            return hasScheduledTrackers
        }
        
        var perfectDays = scheduledDates.filter { date in
            return trackerStore.fetchIncompleteTrackers(by: date)?.isEmpty ?? false
        }
        
        if let selectedWeekday = WeekDay.fromDate(today) {
            let predicate = NSPredicate(format: "schedule CONTAINS[cd] %@", selectedWeekday.rawValue)
            self.setupFetchedResultsController(predicate)
            
            let hasScheduledTrackers = fetchedResultsController?.fetchedObjects?.isEmpty == false
            if hasScheduledTrackers {
                let incompleteTrackersToday = trackerStore.fetchIncompleteTrackers(by: today)?.isEmpty ?? false
                if incompleteTrackersToday {
                    perfectDays.append(today)
                }
            }
        }
        
        return perfectDays.count
    }
    
    //MARK: - Среднее значение
    
    public func fetchAverageTrackersPerDay(from earliestDate: Date) -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        var dates: [Date] = []
        var currentDate = calendar.startOfDay(for: earliestDate)
        
        while currentDate <= today {
            dates.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        let totalRecordsCount = fetchAllRecordsCount()
        
        let daysCount = dates.count
        guard daysCount > 0 else { return 0 }
        
        let averageTrackersPerDay = Double(totalRecordsCount) / Double(daysCount)
        
        return Int(round(averageTrackersPerDay))
    }
    
    //MARK: - Лучший период
    
    public func fetchBestPeriod(from earliestDate: Date, trackerStore: TrackerStore) -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        var dates: [Date] = []
        var currentDate = calendar.startOfDay(for: earliestDate)
        
        while currentDate <= today {
            dates.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        var bestPeriod = 0
        var currentStreak = 0
        
        for date in dates {
            guard let scheduledTrackers = try? trackerStore.fetchTrackers(for: date), !scheduledTrackers.isEmpty else {
                continue
            }
            
            let completedTrackers = trackerStore.fetchCompleteTrackers(by: date) ?? []
            var allTrackersMatch = true
            
            for tracker in scheduledTrackers {
                if !completedTrackers.contains(where: { $0.id == tracker.id }) {
                    allTrackersMatch = false
                    break
                }
            }
            
            if allTrackersMatch {
                currentStreak += 1
            } else {
                bestPeriod = max(bestPeriod, currentStreak)
                currentStreak = 0
            }
        }
        
        bestPeriod = max(bestPeriod, currentStreak)
        
        return bestPeriod
    }
    
    //MARK: - Public
    
    public func updateStatistics(with earliestRecordDate: Date, trackerStore: TrackerStore) {
        perfectDaysCount = self.fetchPerfectDaysCount(from: earliestRecordDate, trackerStore: trackerStore)
        averageCount = self.fetchAverageTrackersPerDay(from: earliestRecordDate)
        bestPeriodCount = self.fetchBestPeriod(from: earliestRecordDate, trackerStore: trackerStore)
        trackersCompleteCount = self.fetchAllRecordsCount()
    }
    
    public func clearStatistics() {
        perfectDaysCount = 0
        averageCount = 0
        bestPeriodCount = 0
        trackersCompleteCount = 0
    }
}

