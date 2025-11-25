//
//  MockCalorieGoalRepository.swift
//  CalorieСalculatorTests
//
//  Created by Иван Дроботов on 11/25/25.
//

import Foundation
@testable import CalorieСalculator

actor MockCalorieGoalRepository: CalorieGoalRepositoryProtocol {
    private var goals: [CalorieGoal] = []
    private var shouldThrowError: Error?
    
    func setGoals(_ goals: [CalorieGoal]) {
        self.goals = goals
    }
    
    func setShouldThrowError(_ error: Error?) {
        self.shouldThrowError = error
    }
    
    func fetchGoal(for date: Date) async throws -> CalorieGoal? {
        if let error = shouldThrowError {
            throw error
        }
        return goals.first { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
    
    func saveOrUpdateGoal(dailyTarget: Int, for date: Date) async throws {
        if let error = shouldThrowError {
            throw error
        }
        
        if let index = goals.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) {
            // Update existing
            goals[index] = CalorieGoal(
                id: goals[index].id,
                dailyCalorieTarget: dailyTarget,
                date: date
            )
        } else {
            // Create new
            let newGoal = CalorieGoal(
                id: UUID(),
                dailyCalorieTarget: dailyTarget,
                date: date
            )
            goals.append(newGoal)
        }
    }
    
    func deleteGoal(id: UUID) async throws {
        if let error = shouldThrowError {
            throw error
        }
        goals.removeAll { $0.id == id }
    }
}

