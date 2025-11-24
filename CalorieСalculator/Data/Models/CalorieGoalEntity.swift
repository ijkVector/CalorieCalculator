//
//  CalorieGoalEntity.swift
//  CalorieСalculator
//
//  Created by Иван Дроботов on 11/24/25.
//

import Foundation
import SwiftData

@Model
final class CalorieGoalEntity {
    @Attribute(.unique) var id: UUID
    var dailyCalorieTarget: Int
    var date: Date
    
    init(id: UUID, dailyCalorieTarget: Int, date: Date) {
        self.id = id
        self.dailyCalorieTarget = dailyCalorieTarget
        self.date = date
    }
    
    convenience init(from goal: CalorieGoal) {
        self.init(
            id: goal.id,
            dailyCalorieTarget: goal.dailyCalorieTarget,
            date: goal.date
        )
    }
    
    convenience init(from dto: CalorieGoalDTO) {
        self.init(
            id: dto.id,
            dailyCalorieTarget: dto.dailyCalorieTarget,
            date: dto.date
        )
    }
}

