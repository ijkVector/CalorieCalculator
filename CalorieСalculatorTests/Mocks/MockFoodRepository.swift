//
//  MockFoodRepository.swift
//  CalorieСalculatorTests
//
//  Created by Иван Дроботов on 11/25/25.
//

import Foundation
@testable import CalorieСalculator

actor MockFoodRepository: FoodRepositoryProtocol {
    private var items: [FoodItem] = []
    private var shouldThrowError: FoodRepositoryError?
    
    func setItems(_ items: [FoodItem]) {
        self.items = items
    }
    
    func setShouldThrowError(_ error: FoodRepositoryError?) {
        self.shouldThrowError = error
    }
    
    func fetchFoodItems(for date: Date) async throws -> [FoodItem] {
        if let error = shouldThrowError {
            throw error
        }
        return items
    }
    
    func createFood(item: FoodItem) async throws {
        if let error = shouldThrowError {
            throw error
        }
        items.append(item)
    }
    
    func updateFood(item: FoodItem) async throws {
        if let error = shouldThrowError {
            throw error
        }
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = item
        }
    }
    
    func deleteFood(id: UUID) async throws {
        if let error = shouldThrowError {
            throw error
        }
        items.removeAll { $0.id == id }
    }
}

