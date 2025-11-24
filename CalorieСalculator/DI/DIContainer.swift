//
//  DIContainer.swift
//  CalorieСalculator
//
//  Created by Иван Дроботов on 11/24/25.
//

import Foundation
import SwiftData

@MainActor
final class DIContainer {
    
    //MARK: - Infrastructure Level
    
    private let modelContainer: ModelContainer
    
    //MARK: - Data Layer
    
    private let foodStore: FoodStoreProtocol
    
    private let foodRepository: FoodRepositoryProtocol
    
    private let goalStore: CalorieGoalStoreProtocol
    
    private let goalRepository: CalorieGoalRepositoryProtocol
    
    //MARK: - Domain Layer
    
    private let foodInputValidator: FoodInputValidating
    
    private let duplicateChecker: FoodDuplicateChecking
    
    //MARK: - Initialization
    
    init() {
        let schema = Schema([
            FoodItemEntity.self,
            CalorieGoalEntity.self
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            let container = try ModelContainer(for: schema, configurations: [config])
            self.modelContainer = container
            
            let foodStore = FoodStore(modelContainer: container)
            self.foodStore = foodStore
            
            let foodRepository = FoodRepository(store: foodStore)
            self.foodRepository = foodRepository
            
            let goalStore = CalorieGoalStore(modelContainer: container)
            self.goalStore = goalStore
            
            let goalRepository = CalorieGoalRepository(store: goalStore)
            self.goalRepository = goalRepository
            
            self.foodInputValidator = FoodInputValidator()
            
            self.duplicateChecker = FoodDuplicateChecker()
            
        } catch {
            fatalError("Failed to create DependencyContainer: \(error.localizedDescription)")
        }
    }
    
    //MARK: - Factories
    
    func makeCalorieViewModel() -> CalorieСalculatorViewModel {
        CalorieСalculatorViewModel(
            repository: foodRepository,
            goalRepository: goalRepository,
            inputValidator: foodInputValidator,
            duplicateChecker: duplicateChecker
        )
    }
}
