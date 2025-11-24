//
//  CalorieGoalDTO.swift
//  CalorieСalculator
//
//  Created by Иван Дроботов on 11/24/25.
//

import Foundation

struct CalorieGoalDTO: Sendable {
    let id: UUID
    let dailyCalorieTarget: Int
    let date: Date
    
    init(id: UUID, dailyCalorieTarget: Int, date: Date) {
        self.id = id
        self.dailyCalorieTarget = dailyCalorieTarget
        self.date = date
    }
    
    init(from entity: CalorieGoalEntity) {
        self.id = entity.id
        self.dailyCalorieTarget = entity.dailyCalorieTarget
        self.date = entity.date
    }
}

