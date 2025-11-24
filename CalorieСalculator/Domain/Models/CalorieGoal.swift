//
//  CalorieGoal.swift
//  CalorieСalculator
//
//  Created by Иван Дроботов on 11/24/25.
//

import Foundation

struct CalorieGoal: Identifiable, Sendable, Equatable {
    let id: UUID
    let dailyCalorieTarget: Int
    let date: Date
    
    init(
        id: UUID = UUID(),
        dailyCalorieTarget: Int,
        date: Date = Date()
    ) {
        self.id = id
        self.dailyCalorieTarget = dailyCalorieTarget
        self.date = date
    }
    
    init(from goalDTO: CalorieGoalDTO) {
        self.init(
            id: goalDTO.id,
            dailyCalorieTarget: goalDTO.dailyCalorieTarget,
            date: goalDTO.date
        )
    }
}

