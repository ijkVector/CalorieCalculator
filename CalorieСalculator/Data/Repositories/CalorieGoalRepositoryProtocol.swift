//
//  CalorieGoalRepositoryProtocol.swift
//  CalorieСalculator
//
//  Created by Иван Дроботов on 11/24/25.
//

import Foundation

protocol CalorieGoalRepositoryProtocol: Sendable {
    func fetchGoal(for date: Date) async throws -> CalorieGoal?
    func saveOrUpdateGoal(dailyTarget: Int, for date: Date) async throws
    func deleteGoal(id: UUID) async throws
}

