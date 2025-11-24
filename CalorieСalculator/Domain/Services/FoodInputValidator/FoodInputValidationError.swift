//
//  FoodInputValidationError.swift
//  CalorieСalculator
//
//  Created by Иван Дроботов on 11/24/25.
//

import Foundation

enum FoodInputValidationError: LocalizedError, Equatable {
    case emptyInput
    case invalidFormat
    case missingName
    case missingCalories
    case caloriesNotNumeric
    case caloriesOutOfRange(value: Int)
    case nameTooShort
    case nameTooLong
    
    var errorDescription: String? {
        switch self {
        case .emptyInput:
            return "Enter food name and calories"
        case .invalidFormat:
            return "Format: 'Food Name 100' (calories at the end)"
        case .missingName:
            return "Food name is required"
        case .missingCalories:
            return "Calories are required"
        case .caloriesNotNumeric:
            return "Calories must be a number"
        case .caloriesOutOfRange(let value):
            return "Calories \(value) out of range (1-10,000)"
        case .nameTooShort:
            return "Food name is too short"
        case .nameTooLong:
            return "Food name is too long (max 100 characters)"
        }
    }
}

