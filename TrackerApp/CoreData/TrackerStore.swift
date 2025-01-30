//
//  TrackerStore.swift
//  TrackerApp
//
//  Created by Maksim on 11.11.2024.
//

import UIKit
import CoreData

protocol TrackerStoreDelegate: AnyObject {
    func didUpdateTrackers()
}

final class TrackerStore: NSObject {
    
    // MARK: - Properties
    
    static let shared = TrackerStore()
    weak var delegate: TrackerStoreDelegate?
    
    private var context: NSManagedObjectContext {
        appDelegate.persistentContainer.viewContext
    }
    
    private var appDelegate: AppDelegate {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("UIApplication.shared.delegate is not of type AppDelegate")
        }
        return delegate
    }
    
    private var lastUsedPredicate: NSPredicate
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>
    
    // MARK: - Initialization
    
    private override init() {
        self.lastUsedPredicate = NSPredicate(value: true)
        
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "isPinned", ascending: false),
            NSSortDescriptor(key: "category.title", ascending: true),
            NSSortDescriptor(key: "title", ascending: true)
        ]
        
        self.fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext,
            sectionNameKeyPath: "pinnedOrCategory",
            cacheName: nil
        )
        
        super.init()
        
        self.fetchedResultsController.delegate = self
        try? self.fetchedResultsController.performFetch()
    }
    
    // MARK: - Public Methods
    
    func trackerObject(at indexPath: IndexPath) -> Tracker? {
        let trackerCoreData = fetchedResultsController.object(at: indexPath)
        return trackerFromCoreData(trackerCoreData)
    }
    
    func header(at section: Int) -> String? {
        fetchedResultsController.sections?[section].name
    }
    
    func numberOfSections() -> Int {
        fetchedResultsController.sections?.count ?? 0
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func createTracker(with tracker: Tracker, in category: TrackerCategoryCoreData) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.id = tracker.id
        trackerCoreData.title = tracker.title
        trackerCoreData.color = tracker.color
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.schedule = tracker.schedule.map { $0.rawValue }.joined(separator: ", ")
        trackerCoreData.category = category
        category.addToTrackers(trackerCoreData)
        
        try context.save()
    }
    
    func removeTracker(with id: UUID) {
        let predicate = NSPredicate(format: "id == %@", id as CVarArg)
        updateFetchedResultsController(with: predicate)
        
        guard let fetchedObjects = fetchedResultsController.fetchedObjects,
              let trackerEntity = fetchedObjects.first else {
            return
        }
        
        context.delete(trackerEntity)
        appDelegate.saveContext()
    }
    
    func fetchTrackerEntity(_ id: UUID) -> TrackerCoreData? {
        let predicate = NSPredicate(format: "id == %@", id as CVarArg)
        updateFetchedResultsController(with: predicate)
        
        guard let fetchedObjects = fetchedResultsController.fetchedObjects else {
            return TrackerCoreData()
        }
        
        let trackerEntity = fetchedObjects.first
        
        return trackerEntity
    }
    
    func fetchTrackers(for date: Date) throws -> [Tracker] {
        guard let weekDay = WeekDay.fromDate(date) else { return [] }
        
        let predicate = NSPredicate(format: "schedule CONTAINS[cd] %@", weekDay.rawValue)
        updateFetchedResultsController(with: predicate)
        
        return fetchedResultsController.fetchedObjects?.compactMap { trackerFromCoreData($0) } ?? []
    }
    
    func fetchCompleteTrackers(by date: Date) -> [Tracker]? {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        guard let selectedWeekday = WeekDay.fromDate(date) else { return [] }
        
        let hasRecordForExactDatePredicate = NSPredicate(
            format: "SUBQUERY(record, $record, $record.date >= %@ AND $record.date < %@).@count > 0",
            startOfDay as NSDate,
            endOfDay as NSDate
        )
        
        let scheduledOnDayPredicate = NSPredicate(format: "schedule CONTAINS[cd] %@", selectedWeekday.rawValue)
        let combinedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [hasRecordForExactDatePredicate, scheduledOnDayPredicate])
        
        updateFetchedResultsController(with: combinedPredicate)
        return fetchedResultsController.fetchedObjects?.compactMap { trackerFromCoreData($0) }
    }
    
    func fetchIncompleteTrackers(by date: Date) -> [Tracker]? {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        guard let selectedWeekday = WeekDay.fromDate(date) else { return [] }
        
        let noRecordForDatePredicate = NSPredicate(
            format: "SUBQUERY(record, $record, $record.date >= %@ AND $record.date < %@).@count == 0",
            startOfDay as NSDate,
            endOfDay as NSDate
        )
        
        let scheduledOnDayPredicate = NSPredicate(format: "schedule CONTAINS[cd] %@", selectedWeekday.rawValue)
        let combinedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [noRecordForDatePredicate, scheduledOnDayPredicate])
        
        updateFetchedResultsController(with: combinedPredicate)
        return fetchedResultsController.fetchedObjects?.compactMap { trackerFromCoreData($0) }
    }
    
    func searchTracker(with title: String) -> [Tracker]? {
        let titlePredicate = NSPredicate(format: "title CONTAINS[cd] %@", title)
        
        if !title.isEmpty {
            updateFetchedResultsController(with: lastUsedPredicate, trackerTitlePredicate: titlePredicate)
        } else {
            updateFetchedResultsController(with: lastUsedPredicate)
        }
        
        return fetchedResultsController.fetchedObjects?.compactMap { trackerFromCoreData($0) }
    }
    
    func updateTracker(for tracker: Tracker, to newCategory: TrackerCategoryCoreData? = nil) {
        guard let trackerCoreData = fetchTrackerEntity(tracker.id) else { return }
        
        trackerCoreData.title = tracker.title
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.color = tracker.color
        trackerCoreData.isPinned = tracker.isPinned
        trackerCoreData.schedule = tracker.schedule.map { $0.rawValue }.joined(separator: ", ")
        
        if let newCategory = newCategory {
            if let oldCategory = trackerCoreData.category {
                oldCategory.removeFromTrackers(trackerCoreData)
            }
            
            trackerCoreData.category = newCategory
            newCategory.addToTrackers(trackerCoreData)
        }
        
        appDelegate.saveContext()
    }
    
    func deleteAllTrackers() throws {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        let trackers = try context.fetch(fetchRequest)
        
        for tracker in trackers {
            context.delete(tracker)
        }
        
        try context.save()
        delegate?.didUpdateTrackers()
    }
    
    // MARK: - Private Methods
    
    private func updateFetchedResultsController(with predicate: NSPredicate, trackerTitlePredicate: NSPredicate? = nil) {
        lastUsedPredicate = predicate
        
        let combinedPredicate = combinePredicates(basePredicate: predicate, titlePredicate: trackerTitlePredicate)
        
        fetchedResultsController.fetchRequest.predicate = combinedPredicate
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Ошибка при выполнении выборки: \(error)")
        }
    }
    
    private func combinePredicates(basePredicate: NSPredicate, titlePredicate: NSPredicate?) -> NSPredicate {
        if let titlePredicate = titlePredicate {
            return NSCompoundPredicate(andPredicateWithSubpredicates: [basePredicate, titlePredicate])
        } else {
            return basePredicate
        }
    }
    
    private func trackerFromCoreData(_ trackerCoreData: TrackerCoreData) -> Tracker? {
        guard let id = trackerCoreData.id,
              let title = trackerCoreData.title,
              let color = trackerCoreData.color,
              let emoji = trackerCoreData.emoji,
              let scheduleString = trackerCoreData.schedule else {
            return nil
        }
        
        let schedule = WeekDay.scheduleFromString(scheduleString)
        return Tracker(
            id: id,
            title: title,
            color: color,
            emoji: emoji,
            schedule: schedule,
            isPinned: trackerCoreData.isPinned
        )
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.didUpdateTrackers()
        }
    }
}

extension WeekDay {
    static func scheduleFromString(_ string: String) -> Set<WeekDay> {
        let daysArray = string.components(separatedBy: ", ")
        let schedule = daysArray.compactMap { dayString in
            WeekDay.allCases.first { $0.rawValue == dayString }
        }
        return Set(schedule)
    }
}
