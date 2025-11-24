//
//  FoodInputValidatorProtocol.swift
//  CalorieСalculator
//
//  Created by Иван Дроботов on 11/24/25.
//

import Foundation

protocol FoodInputValidating: Sendable {
    func validate(_ input: String) throws -> ValidatedFoodInput
}

