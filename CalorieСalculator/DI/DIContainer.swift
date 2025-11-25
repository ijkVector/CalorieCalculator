//
//  DIContainer.swift
//  CalorieСalculator
//
//  Created by Иван Дроботов on 11/24/25.
//

import Foundation
import SwiftData

enum DIContainerError: Error, LocalizedError {
    case modelContainerInitializationFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .modelContainerInitializationFailed(let error):
            return "Failed to initialize storage: \(error.localizedDescription)"
        }
    }
}

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
    
    init() throws {
        let schema = Schema([
            FoodItemEntity.self,
            CalorieGoalEntity.self
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            self.modelContainer = try ModelContainer(
                for: schema,
                configurations: [config]
            )
        } catch {
            throw DIContainerError.modelContainerInitializationFailed(error)
        }
        
        let foodStore = FoodStore(modelContainer: modelContainer)
        self.foodStore = foodStore
        
        let foodRepository = FoodRepository(store: foodStore)
        self.foodRepository = foodRepository
        
        let goalStore = CalorieGoalStore(modelContainer: modelContainer)
        self.goalStore = goalStore
        
        let goalRepository = CalorieGoalRepository(store: goalStore)
        self.goalRepository = goalRepository
        
        self.foodInputValidator = FoodInputValidator()
        
        self.duplicateChecker = FoodDuplicateChecker()
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
