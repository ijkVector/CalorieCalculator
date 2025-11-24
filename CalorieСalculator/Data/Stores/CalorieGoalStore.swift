//
//  CalorieGoalStore.swift
//  CalorieСalculator
//
//  Created by Иван Дроботов on 11/24/25.
//

import Foundation
import SwiftData

final class CalorieGoalStore: CalorieGoalStoreProtocol {
    private let modelContainer: ModelContainer
    
    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }
    
    @MainActor
    func fetchGoal(for date: Date) async throws -> CalorieGoalDTO? {
        let context = modelContainer.mainContext
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = #Predicate<CalorieGoalEntity> { entity in
            entity.date >= startOfDay && entity.date < endOfDay
        }
        
        let descriptor = FetchDescriptor<CalorieGoalEntity>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        do {
            let entities = try context.fetch(descriptor)
            return entities.first.map { CalorieGoalDTO(from: $0) }
        } catch {
            throw CalorieGoalStoreError.fetchFailed(error.localizedDescription)
        }
    }
    
    @MainActor
    func saveGoal(_ goal: CalorieGoalDTO) async throws {
        let context = modelContainer.mainContext
        let entity = CalorieGoalEntity(from: goal)
        
        do {
            context.insert(entity)
            try context.save()
        } catch {
            throw CalorieGoalStoreError.saveFailed(error.localizedDescription)
        }
    }
    
    @MainActor
    func updateGoal(_ goal: CalorieGoalDTO) async throws {
        let context = modelContainer.mainContext
        let goalId = goal.id
        
        let predicate = #Predicate<CalorieGoalEntity> { entity in
            entity.id == goalId
        }
        
        let descriptor = FetchDescriptor<CalorieGoalEntity>(predicate: predicate)
        
        do {
            let entities = try context.fetch(descriptor)
            guard let entity = entities.first else {
                throw CalorieGoalStoreError.notFound
            }
            
            entity.dailyCalorieTarget = goal.dailyCalorieTarget
            entity.date = goal.date
            
            try context.save()
        } catch let error as CalorieGoalStoreError {
            throw error
        } catch {
            throw CalorieGoalStoreError.updateFailed(error.localizedDescription)
        }
    }
    
    @MainActor
    func deleteGoal(id: UUID) async throws {
        let context = modelContainer.mainContext
        
        let predicate = #Predicate<CalorieGoalEntity> { entity in
            entity.id == id
        }
        
        let descriptor = FetchDescriptor<CalorieGoalEntity>(predicate: predicate)
        
        do {
            let entities = try context.fetch(descriptor)
            guard let entity = entities.first else {
                throw CalorieGoalStoreError.notFound
            }
            
            context.delete(entity)
            try context.save()
        } catch let error as CalorieGoalStoreError {
            throw error
        } catch {
            throw CalorieGoalStoreError.deleteFailed(error.localizedDescription)
        }
    }
}

