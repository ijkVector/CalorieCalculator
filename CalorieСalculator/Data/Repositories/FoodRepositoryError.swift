//
//  FoodRepositoryError.swift
//  CalorieСalculator
//
//  Created by Иван Дроботов on 11/23/25.
//

import Foundation

enum FoodRepositoryError: LocalizedError {
    
    case foodItemNotFound(UUID)
    case deviceStorageExhausted
    case duplicateFoodEntry(UUID)
    case invalidDate
    case cannotSaveFood(reason: String)
    case cannotLoadFoods(reason: String)
    
    var errorDescription: String? {
        switch self {
        case .foodItemNotFound(let id):
            return "The food item you're looking for doesn't exist (ID: \(id.uuidString.prefix(8))...)"
            
        case .deviceStorageExhausted:
            return "Your device is out of storage. Please free up space to continue tracking your meals."
            
        case .duplicateFoodEntry(let id):
            return "This food item has already been added (ID: \(id.uuidString.prefix(8))...)"
            
        case .invalidDate:
            return "Cannot process the selected date. Please try a different date."
            
        case .cannotSaveFood(let reason):
            return "Unable to save food item: \(reason)"
            
        case .cannotLoadFoods(let reason):
            return "Unable to load your meals: \(reason)"
        }
    }
    
    // MARK: - User-Friendly Messages
    
    var userFacingMessage: String {
        switch self {
        case .foodItemNotFound:
            return "Food item not found"
        case .deviceStorageExhausted:
            return "Storage full"
        case .duplicateFoodEntry:
            return "Item already exists"
        case .invalidDate:
            return "Invalid date"
        case .cannotSaveFood:
            return "Cannot save item"
        case .cannotLoadFoods:
            return "Cannot load meals"
        }
    }
}
