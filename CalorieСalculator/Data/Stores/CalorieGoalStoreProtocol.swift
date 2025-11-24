//
//  CalorieGoalStoreProtocol.swift
//  CalorieСalculator
//
//  Created by Иван Дроботов on 11/24/25.
//

import Foundation

protocol CalorieGoalStoreProtocol: Sendable {
    func fetchGoal(for date: Date) async throws -> CalorieGoalDTO?
    func saveGoal(_ goal: CalorieGoalDTO) async throws
    func updateGoal(_ goal: CalorieGoalDTO) async throws
    func deleteGoal(id: UUID) async throws
}

