//
//  FoodItemDTO.swift
//  CalorieСalculator
//
//  Created by Иван Дроботов on 11/24/25.
//

import Foundation

struct FoodItemDTO: Sendable {
    let id: UUID
    let name: String
    let calories: Int
    let imageData: Data?
    let timestamp: Date
    
    init(
        id: UUID,
        name: String,
        calories: Int,
        imageData: Data?,
        timestamp: Date
    ) {
        self.id = id
        self.name = name
        self.calories = calories
        self.imageData = imageData
        self.timestamp = timestamp
    }
    
    init(from item: FoodItem) {
        self.id = item.id
        self.name = item.name
        self.calories = item.calories
        self.imageData = item.imageData
        self.timestamp = item.timestamp
    }
    
    func toEntity() -> FoodItemEntity {
        FoodItemEntity(
            id: id,
            name: name,
            calories: calories,
            imageData: imageData,
            timestamp: timestamp
        )
    }
}
