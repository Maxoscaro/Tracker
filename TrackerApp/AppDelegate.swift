//
//  AppDelegate.swift
//  TrackerApp
//
//  Created by Maksim on 04.10.2024.
//

import UIKit
import CoreData
import YandexMobileMetrica

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    let fileManager = FileManager.default
    
    func deleteCoreDataStore() {
        if let storeURL = self.persistentContainer.persistentStoreDescriptions.first?.url {
            do {
                try fileManager.removeItem(at: storeURL)
                print("Database deleted successfully.")
            } catch {
                print("Failed to delete database: \(error.localizedDescription)")
            }
        }
    }
    
    func resetPersistentStore() {
        let persistentStoreCoordinator = persistentContainer.persistentStoreCoordinator
        for store in persistentStoreCoordinator.persistentStores {
            guard let storeURL = store.url else {
                print("Store URL is nil, skipping this store.")
                continue
            }
            do {
                try persistentStoreCoordinator.remove(store)
                try fileManager.removeItem(at: storeURL)
                try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
            } catch {
                print("Failed to reset persistent store: \(error.localizedDescription)")
            }
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        guard let configuration = YMMYandexMetricaConfiguration(apiKey: "84e36de0-9bf9-4082-a43b-e35cd4cd3293") else {
            return true
        }
            
        YMMYandexMetrica.activate(with: configuration)
        return true
    } 

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        let analyticsService = AnalyticsService()
        let analyticsEvent = AnalyticsEvent(
            eventType: .close,
            screen: "Main",
            item: nil
        )
        print("Close TrackerApp tapped")
        analyticsService.sendEvent(analyticsEvent)
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
      
        let container = NSPersistentContainer(name: "TrackerApp")
        let description = container.persistentStoreDescriptions.first
        description?.shouldMigrateStoreAutomatically = true
        description?.shouldInferMappingModelAutomatically = true
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

