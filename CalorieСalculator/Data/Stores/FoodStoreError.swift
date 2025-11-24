//
//  FoodStoreError.swift
//  CalorieСalculator
//
//  Created by Иван Дроботов on 11/24/25.
//

import Foundation

enum FoodStoreError: LocalizedError {
    case itemNotFound(UUID)
    case storageFull
    case duplicateItem(UUID)
    case saveFailed(Error)
    case fetchFailed(Error)
    case invalidDateRange
    
    var errorDescription: String? {
        switch self {
        case .itemNotFound(let id):
            return "Item with id \(id.uuidString) not found in database"
        case .storageFull:
            return "Device storage is full. Please free up space."
        case .duplicateItem(let id):
            return "Item with id \(id.uuidString) already exists"
        case .saveFailed(let error):
            return "Failed to save item: \(error.localizedDescription)"
        case .fetchFailed(let error):
            return "Failed to fetch items: \(error.localizedDescription)"
        case .invalidDateRange:
            return "Failed to calculate date range. Invalid date provided."
        }
    }
}
