//
//  CalorieGoalStoreError.swift
//  CalorieСalculator
//
//  Created by Иван Дроботов on 11/24/25.
//

import Foundation

enum CalorieGoalStoreError: LocalizedError, Sendable {
    case saveFailed(String)
    case fetchFailed(String)
    case updateFailed(String)
    case deleteFailed(String)
    case notFound
    
    var errorDescription: String? {
        switch self {
        case .saveFailed(let message):
            return "Failed to save calorie goal: \(message)"
        case .fetchFailed(let message):
            return "Failed to fetch calorie goal: \(message)"
        case .updateFailed(let message):
            return "Failed to update calorie goal: \(message)"
        case .deleteFailed(let message):
            return "Failed to delete calorie goal: \(message)"
        case .notFound:
            return "Calorie goal not found"
        }
    }
}

