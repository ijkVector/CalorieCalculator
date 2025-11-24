//
//  FoodItem.swift
//  CalorieСalculator
//
//  Created by Иван Дроботов on 11/23/25.
//

import Foundation

struct FoodItem: Identifiable, Sendable {
    let id: UUID
    let name: String
    let calories: Int
    let imageData: Data?
    let timestamp: Date
    
    init(
        id: UUID = UUID(),
        name: String, calories: Int,
        imageData: Data? = nil,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.calories = calories
        self.timestamp = timestamp
        self.imageData = imageData
    }
    
    init(from itemDTO: FoodItemDTO) {
        self.init(
            id: itemDTO.id,
            name: itemDTO.name,
            calories: itemDTO.calories,
            imageData: itemDTO.imageData,
            timestamp: itemDTO.timestamp
        )
    }
}
