//
//  FoodInputValidator.swift
//  CalorieСalculator
//
//  Created by Иван Дроботов on 11/24/25.
//

import Foundation

struct FoodInputValidator: FoodInputValidating {
    
    // MARK: - FoodInputValidating Implementation
    
    func validate(_ input: String) throws -> ValidatedFoodInput {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw FoodInputValidationError.emptyInput
        }
        
        let components = trimmed.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
        
        guard components.count >= 2 else {
            throw FoodInputValidationError.invalidFormat
        }
        
        guard let lastComponent = components.last,
              let calories = Int(lastComponent) else {
            throw FoodInputValidationError.caloriesNotNumeric
        }
        
        guard CalorieValidationRules.isValid(calories) else {
            throw FoodInputValidationError.caloriesOutOfRange(value: calories)
        }
        
        let nameComponents = components.dropLast()
        let name = nameComponents.joined(separator: " ")
        
        guard !name.isEmpty else {
            throw FoodInputValidationError.missingName
        }
        
        guard NameValidationRules.isValid(name) else {
            if name.count < NameValidationRules.minimumLength {
                throw FoodInputValidationError.nameTooShort
            } else {
                throw FoodInputValidationError.nameTooLong
            }
        }
        
        return ValidatedFoodInput(
            name: name,
            calories: calories,
            originalInput: input
        )
    }
}
