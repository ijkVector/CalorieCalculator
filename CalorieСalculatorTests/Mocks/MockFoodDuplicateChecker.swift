//
//  MockFoodDuplicateChecker.swift
//  CalorieСalculatorTests
//
//  Created by Иван Дроботов on 11/25/25.
//

import Foundation
@testable import CalorieСalculator

final class MockFoodDuplicateChecker: FoodDuplicateChecking {
    var checkResult: DuplicateCheckResult = .unique
    
    func setCheckResult(_ result: DuplicateCheckResult) {
        self.checkResult = result
    }
    
    func checkForDuplicate(name: String, in items: [FoodItem]) -> DuplicateCheckResult {
        return checkResult
    }
}

