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
            return "Введите название еды и калории"
        case .invalidFormat:
            return "Формат: 'Название еды 100' (калории в конце)"
        case .missingName:
            return "Требуется название еды"
        case .missingCalories:
            return "Требуются калории"
        case .caloriesNotNumeric:
            return "Калории должны быть числом"
        case .caloriesOutOfRange(let value):
            return "Калории \(value) вне диапазона (1-10 000)"
        case .nameTooShort:
            return "Название еды слишком короткое"
        case .nameTooLong:
            return "Название еды слишком длинное (макс 100 символов)"
        }
    }
}

