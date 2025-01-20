//
//  CategoryViewModel.swift
//  TrackerApp
//
//  Created by Maksim on 11.01.2025.
//

import Foundation

final class CreateCategoryViewModel {
    weak var trackersCategoryStore: TrackerCategoryStore?
    
    var onCategoryCreation: Binding<String>?
    var onCreationButtonStateUpdate: Binding<Bool>?
    
    var categoryName: String = "" {
            didSet {
                onCategoryCreation?(categoryName)
            }
        }
        
        var isDoneButtonEnabled: Bool {
            return !categoryName.isEmpty
        }
    
    func createNewCategory() {
        guard !categoryName.isEmpty else { return }
        let newCategory = TrackerCategory(title: categoryName, trackers: [])
        trackersCategoryStore?.createTrackerCategory(with: newCategory)
        print("New category created: \(categoryName)")
    
                }
    
    
    func updateButtonState() {
        onCreationButtonStateUpdate?(isDoneButtonEnabled)
    }
}
