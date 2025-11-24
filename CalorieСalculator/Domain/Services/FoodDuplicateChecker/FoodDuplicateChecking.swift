//
//  FoodDuplicateCheckerProtocol.swift
//  CalorieСalculator
//
//  Created by Иван Дроботов on 11/24/25.
//

import Foundation

protocol FoodDuplicateChecking: Sendable {
    
    func checkForDuplicate(
        name: String,
        in items: [FoodItem]
    ) -> DuplicateCheckResult
}
