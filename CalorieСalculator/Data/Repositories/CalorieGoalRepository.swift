//
//  CalorieGoalRepository.swift
//  CalorieСalculator
//
//  Created by Иван Дроботов on 11/24/25.
//

import Foundation

actor CalorieGoalRepository: CalorieGoalRepositoryProtocol {
    private let store: CalorieGoalStoreProtocol
    
    init(store: CalorieGoalStoreProtocol) {
        self.store = store
    }
    
    func fetchGoal(for date: Date) async throws -> CalorieGoal? {
        do {
            guard let goalDTO = try await store.fetchGoal(for: date) else {
                return nil
            }
            return CalorieGoal(from: goalDTO)
        } catch {
            throw CalorieGoalRepositoryError.fetchFailed(error.localizedDescription)
        }
    }
    
    func saveOrUpdateGoal(dailyTarget: Int, for date: Date) async throws {
        // Validate target
        guard dailyTarget > 0 else {
            throw CalorieGoalRepositoryError.invalidTarget("Calorie target must be greater than 0")
        }
        
        guard dailyTarget <= 10000 else {
            throw CalorieGoalRepositoryError.invalidTarget("Calorie target cannot exceed 10,000")
        }
        
        do {
            // Check if goal already exists for this date
            if let existingGoal = try await store.fetchGoal(for: date) {
                // Update existing goal
                let updatedGoal = CalorieGoalDTO(
                    id: existingGoal.id,
                    dailyCalorieTarget: dailyTarget,
                    date: date
                )
                try await store.updateGoal(updatedGoal)
            } else {
                // Create new goal
                let newGoal = CalorieGoalDTO(
                    id: UUID(),
                    dailyCalorieTarget: dailyTarget,
                    date: date
                )
                try await store.saveGoal(newGoal)
            }
        } catch let error as CalorieGoalRepositoryError {
            throw error
        } catch {
            throw CalorieGoalRepositoryError.saveFailed(error.localizedDescription)
        }
    }
    
    func deleteGoal(id: UUID) async throws {
        do {
            try await store.deleteGoal(id: id)
        } catch {
            throw CalorieGoalRepositoryError.deleteFailed(error.localizedDescription)
        }
    }
}

