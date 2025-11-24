//
//  ValidatedFoodInput.swift
//  CalorieСalculator
//
//  Created by Иван Дроботов on 11/24/25.
//

import Foundation

struct ValidatedFoodInput: Equatable, Sendable {
    let name: String
    let calories: Int
    let originalInput: String
    
    init(name: String, calories: Int, originalInput: String) {
        self.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        self.calories = calories
        self.originalInput = originalInput
    }
}

