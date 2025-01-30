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
    
    private var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData>?
    
    func setupFetchedResultsController(_ predicate: NSPredicate) {
        let fetchRequest = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        fetchRequest.predicate = predicate
        
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
    }
    
    // MARK: - Public Methods
    
    func fetchTrackerRecords(for trackerId: UUID) -> [TrackerRecord] {
        let fetchRequest = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        fetchRequest.predicate = NSPredicate(format: "tracker.id == %@", trackerId as CVarArg)
        
        do {
            let records = try context.fetch(fetchRequest)
            print("Found \(records.count) total records for tracker \(trackerId)")
            return records.compactMap { record in
                guard let date = record.date,
                      let tracker = record.tracker,
                      let id = tracker.id else {
                    return nil
                }
                return TrackerRecord(trackerId: id, date: date)
            }
        } catch {
            print("Error fetching all records: \(error)")
            return []
        }
    }
    
    func fetchAllTrackerRecords() -> [TrackerRecord] {
        let predicate = NSPredicate(value: true)
        setupFetchedResultsController(predicate)
        guard let fetchedObjects = fetchedResultsController?.fetchedObjects else { return [] }
        return fetchedObjects.compactMap { entity in
            guard let date = entity.date, let tracker = entity.tracker, let id = tracker.id else { return nil }
            return TrackerRecord(trackerId: id, date: date)
        }
    }
    
    func createTrackerRecord(with trackerCoreData: TrackerCoreData, on date: Date) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        
        let fetchRequest = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        fetchRequest.predicate = NSPredicate(
            format: "tracker.id == %@ AND date >= %@ AND date < %@",
            trackerCoreData.id! as CVarArg,
            startOfDay as NSDate,
            calendar.date(byAdding: .day, value: 1, to: startOfDay)! as NSDate
        )
        
        do {
            let existingRecords = try context.fetch(fetchRequest)
            if !existingRecords.isEmpty {
                print("Record already exists for this date")
                return
            }
            
            let recordCoreData = TrackerRecordCoreData(context: context)
            recordCoreData.date = startOfDay  // Сохраняем начало дня
            recordCoreData.tracker = trackerCoreData
            
            try context.save()
            print("TrackerRecord создан успешно")
        } catch {
            print("Ошибка при работе с CoreData: \(error)")
        }
    }
    
    func removeTrackerRecord(with trackerId: UUID, on date: Date) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return
        }
        
        let fetchRequest = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        fetchRequest.predicate = NSPredicate(
            format: "tracker.id == %@ AND date >= %@ AND date < %@",
            trackerId as CVarArg,
            startOfDay as NSDate,
            endOfDay as NSDate
        )
        
        do {
            let records = try context.fetch(fetchRequest)
            for record in records {
                context.delete(record)
            }
            try context.save()
            print("TrackerRecord успешно удален")
        } catch {
            print("Ошибка при удалении записи: \(error)")
        }
    }
    
    func fetchTrackerRecords(byId trackerId: UUID, on date: Date) -> [TrackerRecord] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return []
        }
        
        let fetchRequest = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        fetchRequest.predicate = NSPredicate(
            format: "tracker.id == %@ AND date >= %@ AND date < %@",
            trackerId as CVarArg,
            startOfDay as NSDate,
            endOfDay as NSDate
        )
        
        do {
            let records = try context.fetch(fetchRequest)
            return records.compactMap { record in
                guard let date = record.date,
                      let tracker = record.tracker,
                      let id = tracker.id else {
                    return nil
                }
                return TrackerRecord(trackerId: id, date: date)
            }
        } catch {
            print("Ошибка при получении записей: \(error)")
            return []
        }
    }
    
    func deleteAllRecords() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "TrackerRecordCoreData")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        batchDeleteRequest.resultType = .resultTypeObjectIDs
        do {
            let result = try context.execute(batchDeleteRequest) as? NSBatchDeleteResult
            guard let objectIDs = result?.result as? [NSManagedObjectID] else { return }
            
            let changes = [NSDeletedObjectsKey: objectIDs]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context])
            
            print("Все записи успешно удалены")
        } catch {
            print("Ошибка при удалении всех записей: \(error)")
        }
    }
    
    func fetchEarliestTrackerRecord() -> TrackerRecord? {
        let fetchRequest = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        fetchRequest.fetchLimit = 1 // Нам нужна только самая ранняя запись
        
        do {
            let records = try context.fetch(fetchRequest)
            guard let earliestRecord = records.first,
                  let date = earliestRecord.date,
                  let tracker = earliestRecord.tracker,
                  let id = tracker.id else {
                print("Failed to unwrap required properties from CoreData record")
                return nil
            }
            
            print("Found earliest record with date: \(date)")
            return TrackerRecord(trackerId: id, date: date)
        } catch {
            print("Error fetching earliest record: \(error)")
            return nil
        }
    }
}

