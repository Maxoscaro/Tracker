//
//  TrackerRecordStore.swift
//  TrackerApp
//
//  Created by Maksim on 11.11.2024.
//

import UIKit
import CoreData

final class TrackerRecordStore: NSObject {
    
    // MARK: - Properties
    
    static let shared = TrackerRecordStore()
    private override init() {
    }

    private var context: NSManagedObjectContext {
        appDelegate.persistentContainer.viewContext
    }
    
    private var appDelegate: AppDelegate {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("UIApplication.shared.delegate is not of type AppDelegate")
        }
        return delegate
    }
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData> = {
        let fetchRequest = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
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
    
    func fetchTrackerRecords(for trackerId: UUID, on date: Date) -> [TrackerRecordCoreData] {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(
            format: "tracker.id == %@ AND date == %@",
            trackerId as CVarArg,
            date as NSDate
        )
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching tracker records: \(error)")
            return []
        }
    }

    func createTrackerRecord(with trackerCoreData: TrackerCoreData, on date: Date) {
        guard let recordEntityDescription = NSEntityDescription.entity(forEntityName: "TrackerRecordCoreData", in: context) else {
            print("Failed to record entity description")
            return
        }
        let recordCoreData = TrackerRecordCoreData(entity: recordEntityDescription, insertInto: context)
        recordCoreData.date = date
        recordCoreData.tracker = trackerCoreData
        appDelegate.saveContext()
    }
}
