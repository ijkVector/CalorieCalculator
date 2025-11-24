//
//  FoodRepositoryProtocol.swift
//  CalorieСalculator
//
//  Created by Иван Дроботов on 11/23/25.
//

import Foundation

protocol FoodRepositoryProtocol: Actor {
    func fetchFoodItems(for date: Date) async throws -> [FoodItem]
    func createFood(item: FoodItem) async throws
    func updateFood(item: FoodItem) async throws
    func deleteFood(id: UUID) async throws
}
