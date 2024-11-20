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
        fetchedResultsController
        createDefaultCategoryIfNeeded()
    }
    
    var chooseCategoryVC: ChooseCategoryViewController?
    private var context: NSManagedObjectContext {
        appDelegate.persistentContainer.viewContext
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
    
    func addNewCategory(_ category: TrackerCategory) throws {
        let categoryCoreData = TrackerCategoryCoreData(context: context)
        categoryCoreData.title = category.title
        try context.save()
    }
    
    func deleteCategory(at indexPath: IndexPath) throws {
        let category = fetchedResultsController.object(at: indexPath)
        context.delete(category)
        try context.save()
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
            let categoryCoreData = try context.fetch(request) as? [TrackerCategoryCoreData]
            return categoryCoreData?.first
        } catch {
            print("Ошибка при загрузке категории: \(error.localizedDescription)")
        }
        return nil
    }

    // MARK: - Private Methods
    
        private func createDefaultCategoryIfNeeded() {
            let defaultCategoryTitle = "Важное"
            if getCategoryBy(title: defaultCategoryTitle) == nil {
                let defaultCategory = TrackerCategory(title: defaultCategoryTitle, trackers: [])
                do {
                    try addNewCategory(defaultCategory)
                    print("Создана дефолтная категория: \(defaultCategoryTitle)")
                } catch {
                    print("Ошибка при создании дефолтной категории: \(error)")
                }
            }
        }
        
    private func createTrackerCategory(with category: TrackerCategory) {
        guard let categoryEntityDescription = NSEntityDescription.entity(forEntityName: "TrackerCategoryCoreData", in: context) else {
            print("Failed to make category entity description")
            return
        }
        
        let categoryCoreData = TrackerCategoryCoreData(entity: categoryEntityDescription, insertInto: context)
        categoryCoreData.title = category.title
        categoryCoreData.trackers = []
        appDelegate.saveContext()
    }
}


