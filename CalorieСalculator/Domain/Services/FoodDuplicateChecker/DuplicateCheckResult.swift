//
//  DuplicateCheckResult.swift
//  CalorieСalculator
//
//  Created by Иван Дроботов on 11/24/25.
//

import Foundation

enum DuplicateCheckResult: Equatable, Sendable {
    case unique
    
    case duplicate(existingItem: FoodItem)
}

