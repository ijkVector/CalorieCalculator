//
//  FoodStoreProtocol.swift
//  CalorieСalculator
//
//  Created by Иван Дроботов on 11/23/25.
//

import Foundation

protocol FoodStoreProtocol: Actor {
    func fetchItems(for date: Date) throws -> [FoodItemDTO]
    func create(item: FoodItemDTO) throws
    func update(item: FoodItemDTO) throws
    func delete(id: UUID) throws
}
