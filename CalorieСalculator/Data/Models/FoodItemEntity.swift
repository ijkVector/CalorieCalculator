//
//  Item.swift
//  CalorieСalculator
//
//  Created by Иван Дроботов on 11/23/25.
//

import Foundation
import SwiftData

@Model
final class FoodItemEntity {
    
    @Attribute(.unique)
    var id: UUID
    var name: String
    var calories: Int
    var imageData: Data?
    var timestamp: Date
    
    init(
        id: UUID = UUID(),
        name: String,
        calories: Int,
        imageData: Data? = nil,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.calories = calories
        self.imageData = imageData
        self.timestamp = timestamp
    }
}
