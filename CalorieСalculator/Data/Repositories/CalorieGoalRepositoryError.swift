//
//  CalorieGoalRepositoryError.swift
//  CalorieСalculator
//
//  Created by Иван Дроботов on 11/24/25.
//

import Foundation

enum CalorieGoalRepositoryError: LocalizedError, Sendable {
    case saveFailed(String)
    case fetchFailed(String)
    case deleteFailed(String)
    case invalidTarget(String)
    
    var errorDescription: String? {
        switch self {
        case .saveFailed(let message):
            return "Failed to save goal: \(message)"
        case .fetchFailed(let message):
            return "Failed to fetch goal: \(message)"
        case .deleteFailed(let message):
            return "Failed to delete goal: \(message)"
        case .invalidTarget(let message):
            return "Invalid goal target: \(message)"
        }
    }
    
    var userFacingMessage: String {
        switch self {
        case .saveFailed:
            return "Unable to save calorie goal. Please try again."
        case .fetchFailed:
            return "Unable to load calorie goal. Please try again."
        case .deleteFailed:
            return "Unable to delete calorie goal. Please try again."
        case .invalidTarget(let message):
            return message
        }
    }
}

