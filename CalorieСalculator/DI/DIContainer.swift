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
    
    //MARK: - Domain Layer
    
    private let foodInputValidator: FoodInputValidating
    
    
    //MARK: - Initialization
    
    init() {
        let schema = Schema([FoodItemEntity.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            let container = try ModelContainer(for: schema, configurations: [config])
            self.modelContainer = container
            
            let store = FoodStore(modelContainer: container)
            self.foodStore = store
            
            let repository = FoodRepository(store: store)
            self.foodRepository = repository
            
            self.foodInputValidator = FoodInputValidator()
            
        } catch {
            fatalError("Failed to create DependencyContainer: \(error.localizedDescription)")
        }
    }
    
    //MARK: - Factories
    
    func makeCalorieViewModel() -> CalorieСalculatorViewModel {
        CalorieСalculatorViewModel(
            repository: foodRepository,
            inputValidator: foodInputValidator
        )
    }
}
