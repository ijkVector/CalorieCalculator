//
//  CalorieCalculatorViewModelTests.swift
//  CalorieСalculatorTests
//
//  Created by Иван Дроботов on 11/25/25.
//

import Testing
import Foundation
@testable import CalorieСalculator

@MainActor
@Suite("CalorieCalculatorViewModel Tests")
struct CalorieCalculatorViewModelTests {
    
    // MARK: - Load Food Items Tests
    
    @Test("Load food items successfully")
    func loadFoodItemsSuccess() async throws {
        // Given
        let mockFoodRepo = MockFoodRepository()
        let mockGoalRepo = MockCalorieGoalRepository()
        let mockValidator = MockFoodInputValidator()
        let mockDuplicateChecker = MockFoodDuplicateChecker()
        
        let testItems = [
            FoodItem(id: UUID(), name: "Apple", calories: 52, imageData: nil, timestamp: Date()),
            FoodItem(id: UUID(), name: "Banana", calories: 89, imageData: nil, timestamp: Date())
        ]
        await mockFoodRepo.setItems(testItems)
        
        let sut = CalorieСalculatorViewModel(
            repository: mockFoodRepo,
            goalRepository: mockGoalRepo,
            inputValidator: mockValidator,
            duplicateChecker: mockDuplicateChecker
        )
        
        // When
        await sut.loadFoodItems()
        
        // Then
        #expect(sut.items.count == 2)
        #expect(sut.totalCalories == 141)
        #expect(!sut.isLoading)
    }
    
    @Test("Load food items handles error")
    func loadFoodItemsError() async throws {
        // Given
        let mockFoodRepo = MockFoodRepository()
        let mockGoalRepo = MockCalorieGoalRepository()
        let mockValidator = MockFoodInputValidator()
        let mockDuplicateChecker = MockFoodDuplicateChecker()
        
        await mockFoodRepo.setShouldThrowError(.cannotLoadFoods(reason: "Test error"))
        
        let sut = CalorieСalculatorViewModel(
            repository: mockFoodRepo,
            goalRepository: mockGoalRepo,
            inputValidator: mockValidator,
            duplicateChecker: mockDuplicateChecker
        )
        
        // When
        await sut.loadFoodItems()
        
        // Then
        #expect(sut.items.isEmpty)
        #expect(sut.showErrorAlert == true)
        #expect(sut.errorMessage != nil)
    }
    
    // MARK: - Add Food Item Tests
    
    @Test("Add food item successfully")
    func addFoodItemSuccess() async throws {
        // Given
        let mockFoodRepo = MockFoodRepository()
        let mockGoalRepo = MockCalorieGoalRepository()
        let mockValidator = MockFoodInputValidator()
        let mockDuplicateChecker = MockFoodDuplicateChecker()
        
        mockValidator.setValidationResult(.success(
            ValidatedFoodInput(name: "Apple", calories: 52, originalInput: "Apple 52")
        ))
        mockDuplicateChecker.setCheckResult(.unique)
        
        let sut = CalorieСalculatorViewModel(
            repository: mockFoodRepo,
            goalRepository: mockGoalRepo,
            inputValidator: mockValidator,
            duplicateChecker: mockDuplicateChecker
        )
        
        // When
        await sut.addFoodItem(input: "Apple 52")
        
        // Then
        #expect(sut.items.count == 1)
        #expect(sut.items.first?.name == "Apple")
        #expect(sut.items.first?.calories == 52)
        #expect(sut.totalCalories == 52)
    }
    
    @Test("Add food item shows error on validation failure")
    func addFoodItemValidationError() async throws {
        // Given
        let mockFoodRepo = MockFoodRepository()
        let mockGoalRepo = MockCalorieGoalRepository()
        let mockValidator = MockFoodInputValidator()
        let mockDuplicateChecker = MockFoodDuplicateChecker()
        
        mockValidator.setValidationResult(.failure(.emptyInput))
        
        let sut = CalorieСalculatorViewModel(
            repository: mockFoodRepo,
            goalRepository: mockGoalRepo,
            inputValidator: mockValidator,
            duplicateChecker: mockDuplicateChecker
        )
        
        // When
        await sut.addFoodItem(input: "")
        
        // Then
        #expect(sut.showErrorAlert == true)
        #expect(sut.errorMessage != nil)
        #expect(sut.items.isEmpty)
    }
    
    @Test("Add food item shows duplicate alert when duplicate detected")
    func addFoodItemDuplicateDetected() async throws {
        // Given
        let mockFoodRepo = MockFoodRepository()
        let mockGoalRepo = MockCalorieGoalRepository()
        let mockValidator = MockFoodInputValidator()
        let mockDuplicateChecker = MockFoodDuplicateChecker()
        
        let existingItem = FoodItem(id: UUID(), name: "Apple", calories: 50, imageData: nil, timestamp: Date())
        
        mockValidator.setValidationResult(.success(
            ValidatedFoodInput(name: "Apple", calories: 52, originalInput: "Apple 52")
        ))
        mockDuplicateChecker.setCheckResult(.duplicate(existingItem: existingItem))
        
        let sut = CalorieСalculatorViewModel(
            repository: mockFoodRepo,
            goalRepository: mockGoalRepo,
            inputValidator: mockValidator,
            duplicateChecker: mockDuplicateChecker
        )
        
        // When
        await sut.addFoodItem(input: "Apple 52")
        
        // Then
        #expect(sut.showDuplicateAlert == true)
        #expect(sut.duplicateItem != nil)
        #expect(sut.items.isEmpty)
    }
    
    // MARK: - Delete Food Item Tests
    
    @Test("Delete food item successfully")
    func deleteFoodItemSuccess() async throws {
        // Given
        let mockFoodRepo = MockFoodRepository()
        let mockGoalRepo = MockCalorieGoalRepository()
        let mockValidator = MockFoodInputValidator()
        let mockDuplicateChecker = MockFoodDuplicateChecker()
        
        let testItem = FoodItem(id: UUID(), name: "Apple", calories: 52, imageData: nil, timestamp: Date())
        await mockFoodRepo.setItems([testItem])
        
        let sut = CalorieСalculatorViewModel(
            repository: mockFoodRepo,
            goalRepository: mockGoalRepo,
            inputValidator: mockValidator,
            duplicateChecker: mockDuplicateChecker
        )
        
        await sut.loadFoodItems()
        #expect(sut.items.count == 1)
        
        // When
        await sut.deleteFoodItem(by: testItem.id)
        
        // Then
        #expect(sut.items.isEmpty)
        #expect(sut.totalCalories == 0)
    }
    
    @Test("Delete food item handles error")
    func deleteFoodItemError() async throws {
        // Given
        let mockFoodRepo = MockFoodRepository()
        let mockGoalRepo = MockCalorieGoalRepository()
        let mockValidator = MockFoodInputValidator()
        let mockDuplicateChecker = MockFoodDuplicateChecker()
        
        await mockFoodRepo.setShouldThrowError(.cannotSaveFood(reason: "Delete failed"))
        
        let sut = CalorieСalculatorViewModel(
            repository: mockFoodRepo,
            goalRepository: mockGoalRepo,
            inputValidator: mockValidator,
            duplicateChecker: mockDuplicateChecker
        )
        
        // When
        await sut.deleteFoodItem(by: UUID())
        
        // Then
        #expect(sut.showErrorAlert == true)
    }
    
    // MARK: - Update Food Item Tests
    
    @Test("Update food item successfully")
    func updateFoodItemSuccess() async throws {
        // Given
        let mockFoodRepo = MockFoodRepository()
        let mockGoalRepo = MockCalorieGoalRepository()
        let mockValidator = MockFoodInputValidator()
        let mockDuplicateChecker = MockFoodDuplicateChecker()
        
        let testItem = FoodItem(id: UUID(), name: "Apple", calories: 52, imageData: nil, timestamp: Date())
        await mockFoodRepo.setItems([testItem])
        
        mockValidator.setValidationResult(.success(
            ValidatedFoodInput(name: "Orange", calories: 62, originalInput: "Orange 62")
        ))
        
        let sut = CalorieСalculatorViewModel(
            repository: mockFoodRepo,
            goalRepository: mockGoalRepo,
            inputValidator: mockValidator,
            duplicateChecker: mockDuplicateChecker
        )
        
        await sut.loadFoodItems()
        
        // When
        await sut.updateFoodItem(originalItem: testItem, input: "Orange 62", imageData: nil)
        
        // Then
        #expect(sut.items.count == 1)
        #expect(sut.items.first?.name == "Orange")
        #expect(sut.items.first?.calories == 62)
    }
    
    // MARK: - Calorie Goal Tests
    
    @Test("Load calorie goal successfully")
    func loadCalorieGoalSuccess() async throws {
        // Given
        let mockFoodRepo = MockFoodRepository()
        let mockGoalRepo = MockCalorieGoalRepository()
        let mockValidator = MockFoodInputValidator()
        let mockDuplicateChecker = MockFoodDuplicateChecker()
        
        let testGoal = CalorieGoal(id: UUID(), dailyCalorieTarget: 2500, date: Date())
        await mockGoalRepo.setGoals([testGoal])
        
        let sut = CalorieСalculatorViewModel(
            repository: mockFoodRepo,
            goalRepository: mockGoalRepo,
            inputValidator: mockValidator,
            duplicateChecker: mockDuplicateChecker
        )
        
        // When
        await sut.loadFoodItems()
        
        // Then
        #expect(sut.calorieGoal?.dailyCalorieTarget == 2500)
        #expect(sut.hasGoal == true)
    }
    
    @Test("Set calorie goal successfully")
    func setCalorieGoalSuccess() async throws {
        // Given
        let mockFoodRepo = MockFoodRepository()
        let mockGoalRepo = MockCalorieGoalRepository()
        let mockValidator = MockFoodInputValidator()
        let mockDuplicateChecker = MockFoodDuplicateChecker()
        
        let sut = CalorieСalculatorViewModel(
            repository: mockFoodRepo,
            goalRepository: mockGoalRepo,
            inputValidator: mockValidator,
            duplicateChecker: mockDuplicateChecker
        )
        
        // When
        await sut.setCalorieGoal(dailyTarget: 2800)
        
        // Then
        #expect(sut.calorieGoal?.dailyCalorieTarget == 2800)
        #expect(sut.hasGoal == true)
    }
    
    // MARK: - Computed Properties Tests
    
    @Test("Total calories calculated correctly")
    func totalCaloriesCalculation() async throws {
        // Given
        let mockFoodRepo = MockFoodRepository()
        let mockGoalRepo = MockCalorieGoalRepository()
        let mockValidator = MockFoodInputValidator()
        let mockDuplicateChecker = MockFoodDuplicateChecker()
        
        let testItems = [
            FoodItem(id: UUID(), name: "Apple", calories: 52, imageData: nil, timestamp: Date()),
            FoodItem(id: UUID(), name: "Banana", calories: 89, imageData: nil, timestamp: Date()),
            FoodItem(id: UUID(), name: "Orange", calories: 62, imageData: nil, timestamp: Date())
        ]
        await mockFoodRepo.setItems(testItems)
        
        let sut = CalorieСalculatorViewModel(
            repository: mockFoodRepo,
            goalRepository: mockGoalRepo,
            inputValidator: mockValidator,
            duplicateChecker: mockDuplicateChecker
        )
        
        // When
        await sut.loadFoodItems()
        
        // Then
        #expect(sut.totalCalories == 203)
    }
    
    @Test("Goal progress calculated correctly")
    func goalProgressCalculation() async throws {
        // Given
        let mockFoodRepo = MockFoodRepository()
        let mockGoalRepo = MockCalorieGoalRepository()
        let mockValidator = MockFoodInputValidator()
        let mockDuplicateChecker = MockFoodDuplicateChecker()
        
        let testItems = [
            FoodItem(id: UUID(), name: "Food1", calories: 500, imageData: nil, timestamp: Date())
        ]
        await mockFoodRepo.setItems(testItems)
        
        let testGoal = CalorieGoal(id: UUID(), dailyCalorieTarget: 1000, date: Date())
        await mockGoalRepo.setGoals([testGoal])
        
        let sut = CalorieСalculatorViewModel(
            repository: mockFoodRepo,
            goalRepository: mockGoalRepo,
            inputValidator: mockValidator,
            duplicateChecker: mockDuplicateChecker
        )
        
        // When
        await sut.loadFoodItems()
        
        // Then
        #expect(sut.goalProgress == 0.5) // 500 / 1000 = 0.5
    }
    
    @Test("Goal progress capped at 1.0")
    func goalProgressCapped() async throws {
        // Given
        let mockFoodRepo = MockFoodRepository()
        let mockGoalRepo = MockCalorieGoalRepository()
        let mockValidator = MockFoodInputValidator()
        let mockDuplicateChecker = MockFoodDuplicateChecker()
        
        let testItems = [
            FoodItem(id: UUID(), name: "Food1", calories: 1500, imageData: nil, timestamp: Date())
        ]
        await mockFoodRepo.setItems(testItems)
        
        let testGoal = CalorieGoal(id: UUID(), dailyCalorieTarget: 1000, date: Date())
        await mockGoalRepo.setGoals([testGoal])
        
        let sut = CalorieСalculatorViewModel(
            repository: mockFoodRepo,
            goalRepository: mockGoalRepo,
            inputValidator: mockValidator,
            duplicateChecker: mockDuplicateChecker
        )
        
        // When
        await sut.loadFoodItems()
        
        // Then
        #expect(sut.goalProgress == 1.0) // Should be capped at 1.0
    }
    
    @Test("Remaining calories calculated correctly")
    func remainingCaloriesCalculation() async throws {
        // Given
        let mockFoodRepo = MockFoodRepository()
        let mockGoalRepo = MockCalorieGoalRepository()
        let mockValidator = MockFoodInputValidator()
        let mockDuplicateChecker = MockFoodDuplicateChecker()
        
        let testItems = [
            FoodItem(id: UUID(), name: "Food1", calories: 500, imageData: nil, timestamp: Date())
        ]
        await mockFoodRepo.setItems(testItems)
        
        let testGoal = CalorieGoal(id: UUID(), dailyCalorieTarget: 2000, date: Date())
        await mockGoalRepo.setGoals([testGoal])
        
        let sut = CalorieСalculatorViewModel(
            repository: mockFoodRepo,
            goalRepository: mockGoalRepo,
            inputValidator: mockValidator,
            duplicateChecker: mockDuplicateChecker
        )
        
        // When
        await sut.loadFoodItems()
        
        // Then
        #expect(sut.remainingCalories == 1500) // 2000 - 500 = 1500
    }
    
    @Test("Goal exceeded detection works correctly")
    func goalExceededDetection() async throws {
        // Given
        let mockFoodRepo = MockFoodRepository()
        let mockGoalRepo = MockCalorieGoalRepository()
        let mockValidator = MockFoodInputValidator()
        let mockDuplicateChecker = MockFoodDuplicateChecker()
        
        let testItems = [
            FoodItem(id: UUID(), name: "Food1", calories: 2500, imageData: nil, timestamp: Date())
        ]
        await mockFoodRepo.setItems(testItems)
        
        let testGoal = CalorieGoal(id: UUID(), dailyCalorieTarget: 2000, date: Date())
        await mockGoalRepo.setGoals([testGoal])
        
        let sut = CalorieСalculatorViewModel(
            repository: mockFoodRepo,
            goalRepository: mockGoalRepo,
            inputValidator: mockValidator,
            duplicateChecker: mockDuplicateChecker
        )
        
        // When
        await sut.loadFoodItems()
        
        // Then
        #expect(sut.isGoalExceeded == true)
        #expect(sut.remainingCalories == 0) // Should be capped at 0
    }
}

