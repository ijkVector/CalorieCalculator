//
//  ValidationRules.swift
//  CalorieСalculator
//
//  Created by Иван Дроботов on 11/24/25.
//

import Foundation

enum CalorieValidationRules {
    static let minimum = 1

    static let maximum = 10_000

    static func isValid(_ calories: Int) -> Bool {
        (minimum...maximum).contains(calories)
    }
}

enum NameValidationRules {
    static let minimumLength = 1

    static let maximumLength = 100
    
    static func isValid(_ name: String) -> Bool {
        (minimumLength...maximumLength).contains(name.count)
    }
}

