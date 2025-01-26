//
//  ChooseCategoryViewModel.swift
//  TrackerApp
//
//  Created by Maksim on 13.01.2025.
//

import Foundation

final class ChooseCategoryViewModel {
    
    var categories: [TrackerCategory] = []
    var selectedCategory: TrackerCategory?
    
    var trackersCategoryStore: TrackerCategoryStore = TrackerCategoryStore.shared
    
    var onCategoriesUpdated: Binding<[TrackerCategory]>?
    var onCategorySelected: Binding<TrackerCategory?>?
    
    func loadCategories() {
        categories = trackersCategoryStore.categories
          onCategoriesUpdated?(categories)
        print("Loaded categories: \(categories.map { $0.title })")
    }

    func selectCategory(at index: Int) {
        selectedCategory = categories[index]
        onCategorySelected?(selectedCategory)
    }
}
