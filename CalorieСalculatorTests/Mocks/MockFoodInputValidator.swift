//
//  MockFoodInputValidator.swift
//  CalorieСalculatorTests
//
//  Created by Иван Дроботов on 11/25/25.
//

import Foundation
@testable import CalorieСalculator

final class MockFoodInputValidator: FoodInputValidating {
    var validationResult: Result<ValidatedFoodInput, FoodInputValidationError>?
    
    func setValidationResult(_ result: Result<ValidatedFoodInput, FoodInputValidationError>) {
        self.validationResult = result
    }
    
    func validate(_ input: String) throws -> ValidatedFoodInput {
        guard let result = validationResult else {
            fatalError("validationResult not set in mock - call setValidationResult() first")
        }
        
        switch result {
        case .success(let validated):
            return validated
        case .failure(let error):
            throw error
        }
    }
}

