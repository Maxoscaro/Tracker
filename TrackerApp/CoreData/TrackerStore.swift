//
//  TrackerStore.swift
//  TrackerApp
//
//  Created by Maksim on 11.11.2024.
//

import UIKit
import CoreData

final class TrackerStore: NSObject {
    
    // MARK: - Properties

    static let shared = TrackerStore()
    private override init() {}
    
        private var context: NSManagedObjectContext {
            appDelegate.persistentContainer.viewContext
        }
    
    private var appDelegate: AppDelegate {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("UIApplication.shared.delegate is not of type AppDelegate")
        }
        return delegate
    }
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: "category.title",
            cacheName: nil
        )
        do {
                try controller.performFetch()
            } catch {
                print("Failed to perform fetch: \(error)")
            }
        return controller
    }()
    
    // MARK: - Public Methods
    
    func tracker(at indexPath: IndexPath) -> Tracker? {
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
    
    func deleteTracker(at indexPath: IndexPath) throws {
        let tracker = fetchedResultsController.object(at: indexPath)
        context.delete(tracker)
        try context.save()
    }
    
    func updateTracker(at indexPath: IndexPath, with newTracker: Tracker) throws {
        let trackerCoreData = fetchedResultsController.object(at: indexPath)
        trackerCoreData.title = newTracker.title
        trackerCoreData.color = newTracker.color
        trackerCoreData.emoji = newTracker.emoji
        trackerCoreData.schedule = newTracker.schedule.map { $0.rawValue }.joined(separator: ", ")
        try context.save()
    }
    
    func fetchTrackers(for date: Date) throws -> [Tracker] {
        guard let weekDay = WeekDay.fromDate(date) else { return [] }
        
        fetchedResultsController.fetchRequest.predicate = NSPredicate(
            format: "schedule CONTAINS[cd] %@",
            weekDay.rawValue
        )
        try fetchedResultsController.performFetch()
        
        return fetchedResultsController.fetchedObjects?
            .compactMap { trackerFromCoreData($0) } ?? []
    }
    
    // MARK: - Private Methods
    
    private func trackerFromCoreData(_ trackerCoreData: TrackerCoreData) -> Tracker? {
        guard let id = trackerCoreData.id,
              let title = trackerCoreData.title,
              let color = trackerCoreData.color,
              let emoji = trackerCoreData.emoji,
              let scheduleString = trackerCoreData.schedule
        else { return nil }
        
        let schedule = WeekDay.scheduleFromString(scheduleString)
        return Tracker(id: id, title: title, color: color, emoji: emoji, schedule: schedule)
    }
    
    private func fetchCategoryCoreData(withTitle title: String) throws -> TrackerCategoryCoreData? {
        let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        request.predicate = NSPredicate(format: "title == %@", title)
        return try context.fetch(request).first
    }
}
// MARK: -  Extensions

extension WeekDay {
    static func scheduleFromString(_ string: String) -> Set<WeekDay> {
        let daysArray = string.components(separatedBy: ", ")
        let schedule = daysArray.compactMap { dayString in
            WeekDay.allCases.first { $0.rawValue == dayString }
        }
        return Set(schedule)
    }
}
