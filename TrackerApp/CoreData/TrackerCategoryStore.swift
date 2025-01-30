//
//  TrackerCategoryStore.swift
//  TrackerApp
//
//  Created by Maksim on 11.11.2024.
//

import UIKit
import CoreData

final class TrackerCategoryStore: NSObject {
    
    // MARK: - Properties
    
    static let shared = TrackerCategoryStore()
    private override init() {
        super.init()
        _ = fetchedResultsController
    }
    
    var chooseCategoryVC: ChooseCategoryViewController?
     var context: NSManagedObjectContext {
        appDelegate.persistentContainer.viewContext
    }
    
    var categories: [TrackerCategory] {
        guard let fetchedObjects = fetchedResultsController.fetchedObjects else {
            print("No fetched objects found")
            return []
        }
        let converted = fetchedObjects.compactMap { entity in
            let category = convertEntityToCategory(entity)
            print("Converting entity with title: \(entity.title ?? "nil")")
            return category
        }
        print("Converted \(converted.count) categories")
        return converted
    }
    
    private var appDelegate: AppDelegate {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("UIApplication.shared.delegate is not of type AppDelegate")
        }
        return delegate
    }
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerCategoryCoreData.title, ascending: true)]
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self
        do {
            try controller.performFetch()
        } catch {
            print("Failed to perform fetch: \(error)")
        }
        return controller
    }()
    
    // MARK: - Public Methods
    
    func category(at indexPath: IndexPath) -> TrackerCategory? {
        let categoryCoreData = fetchedResultsController.object(at: indexPath)
        return TrackerCategory(
            title: categoryCoreData.title ?? "",
            trackers: categoryCoreData.trackers?.allObjects as? [Tracker] ?? []
        )
    }
    
    func addCategory(title: String) -> TrackerCategoryCoreData {
        if let existingCategory = getCategoryBy(title: title) {
            return existingCategory
        }
        let category = TrackerCategoryCoreData(context: context)
        category.title = title
        saveContext()
        return category
    }
    func deleteAllCategories() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "TrackerCategoryCoreData")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
            try fetchedResultsController.performFetch()
        } catch {
            print("Error deleting all categories: \(error)")
        }
    }
    
    func deleteCategory(_ category: TrackerCategoryCoreData) {
           context.delete(category)
           saveContext()
       }
    
    func updateCategory(at indexPath: IndexPath, with newTitle: String) throws {
        let category = fetchedResultsController.object(at: indexPath)
        category.title = newTitle
        try context.save()
    }
    
    func numberOfCategories() -> Int {
        fetchedResultsController.sections?.first?.numberOfObjects ?? 0
    }
    
    func getCategoryBy(title: String) -> TrackerCategoryCoreData? {
        let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        request.predicate = NSPredicate(format: "title == %@", title)
        
        do {
            let categoryCoreData = try context.fetch(request)
            return categoryCoreData.first
        } catch {
            print("Ошибка при загрузке категории: \(error.localizedDescription)")
        }
        return nil
    }
    
    func createTrackerCategory(with category: TrackerCategory) {
        guard let categoryEntityDescription = NSEntityDescription.entity(forEntityName: "TrackerCategoryCoreData", in: context) else {
            print("Failed to make category entity description")
            return
        }
        
        let categoryCoreData = TrackerCategoryCoreData(entity: categoryEntityDescription, insertInto: context)
        categoryCoreData.title = category.title
        categoryCoreData.trackers = []
        do {
            try context.save()
            try fetchedResultsController.performFetch()
            
            NotificationCenter.default.post(name: NSNotification.Name("CategoriesDidChange"), object: nil)
            print("Category saved and reloaded successfully: \(category.title)")
        } catch {
            print("Failed to save or reload category: \(error)")
        }
    }
    
    // MARK: - Private Methods
    
    private func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
    
    private func convertEntityToCategory(_ trackerCategoryCoreData: TrackerCategoryCoreData) -> TrackerCategory? {
        guard let title = trackerCategoryCoreData.title,
              let trackerCoreData = trackerCategoryCoreData.trackers?.allObjects as? [TrackerCoreData] else {
            print("Failed to get title from CoreData entity")
            return nil
        }
        
        let trackers = trackerCoreData.compactMap { trackerCoreData in
            if let id = trackerCoreData.id,
               let title = trackerCoreData.title,
               let color = trackerCoreData.color,
               let emoji = trackerCoreData.emoji,
               let schedule = trackerCoreData.schedule
            {
                return Tracker(id: id, title: title, color: color, emoji: emoji, schedule: WeekDay.scheduleFromString(schedule))
            } else {
                return nil
            }
        }
        return TrackerCategory(title: title, trackers: trackers)
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        NotificationCenter.default.post(name: NSNotification.Name("CategoriesDidChange"), object: nil)
    }
}





