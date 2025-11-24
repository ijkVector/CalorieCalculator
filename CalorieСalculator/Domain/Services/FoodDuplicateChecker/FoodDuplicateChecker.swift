//
//  FoodDuplicateChecker.swift
//  CalorieСalculator
//
//  Created by Иван Дроботов on 11/24/25.
//

import Foundation

struct FoodDuplicateChecker: FoodDuplicateChecking {
    
    // MARK: - FoodDuplicateChecking
    
    func checkForDuplicate(
        name: String,
        in items: [FoodItem]
    ) -> DuplicateCheckResult {
        let normalizedInputName = normalize(name)
        
        guard let duplicateItem = items.first(where: { item in
            normalize(item.name) == normalizedInputName
        }) else {
            return .unique
        }
        
        return .duplicate(existingItem: duplicateItem)
    }
    
    // MARK: - Private Helpers

    private func normalize(_ name: String) -> String {
        name
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
