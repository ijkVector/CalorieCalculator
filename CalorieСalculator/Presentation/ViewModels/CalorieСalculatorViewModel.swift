//
//  CalorieСalculatorViewModel.swift
//  CalorieСalculator
//
//  Created by Иван Дроботов on 11/24/25.
//

import SwiftUI
import Observation

@MainActor
@Observable
final class CalorieСalculatorViewModel {
    
    //MARK: - Dependices
    
    private let foodListrepository: FoodRepositoryProtocol
    private let goalRepository: CalorieGoalRepositoryProtocol
    private let inputValidator: FoodInputValidating
    private let duplicateChecker: FoodDuplicateChecking
    
    //MARK: - Init
    
    init(
        repository: FoodRepositoryProtocol,
        goalRepository: CalorieGoalRepositoryProtocol,
        inputValidator: FoodInputValidating,
        duplicateChecker: FoodDuplicateChecking
    ) {
        self.foodListrepository = repository
        self.goalRepository = goalRepository
        self.inputValidator = inputValidator
        self.duplicateChecker = duplicateChecker
    }
    
    //MARK: - State
    
    private(set) var items: [FoodItem] = []
    private(set) var isLoading: Bool = false
    private(set) var errorMessage: String? = nil
    private(set) var calorieGoal: CalorieGoal? = nil
    
    var showErrorAlert = false
    
    // Alert state для дубликатов
    var showDuplicateAlert = false
    var duplicateAlertTitle = ""
    var duplicateAlertMessage = ""
    var duplicateItem: FoodItem?
    
    // Goal setting state
    var showGoalSheet = false
    
    private var pendingValidatedInput: ValidatedFoodInput?
    
    //MARK: - Computed Properties
    
    var totalCalories: Int {
        items.reduce(0) { $0 + $1.calories }
    }
    
    var isEmpty: Bool {
        items.isEmpty && !isLoading
    }
    
    var hasGoal: Bool {
        calorieGoal != nil
    }
    
    var goalProgress: Double {
        guard let goal = calorieGoal, goal.dailyCalorieTarget > 0 else {
            return 0
        }
        return min(Double(totalCalories) / Double(goal.dailyCalorieTarget), 1.0)
    }
    
    var remainingCalories: Int {
        guard let goal = calorieGoal else {
            return 0
        }
        return max(goal.dailyCalorieTarget - totalCalories, 0)
    }
    
    var isGoalExceeded: Bool {
        guard let goal = calorieGoal else {
            return false
        }
        return totalCalories > goal.dailyCalorieTarget
    }
    
    //MARK: - Actions
    
    func addFoodItem(input: String) async {
        do {
            let validated = try inputValidator.validate(input)
            
            let duplicateResult = duplicateChecker.checkForDuplicate(
                name: validated.name,
                in: items
            )
            
            switch duplicateResult {
            case .unique:
                let newItem = FoodItem(
                    name: validated.name,
                    calories: validated.calories
                )
                try await foodListrepository.createFood(item: newItem)
                await loadFoodItems()
                
            case .duplicate(let existingItem):
                pendingValidatedInput = validated
                showDuplicateAlert(for: existingItem, newCalories: validated.calories)
            }
            
        } catch let error as FoodInputValidationError {
            errorMessage = error.localizedDescription
            showErrorAlert = true
            
        } catch let error as FoodRepositoryError {
            handleDomainError(error)
        } catch {
            handleError(message: error.localizedDescription)
        }
    }
    
    func loadFoodItems(for date: Date = Date()) async {
        isLoading = true
        errorMessage = nil
        
        // Load food items
        do {
            items = try await foodListrepository.fetchFoodItems(for: date)
        } catch let error as FoodRepositoryError {
            handleDomainError(error)
        } catch {
            handleError(message: error.localizedDescription)
        }
        
        // Load goal separately (don't let goal loading errors affect food items)
        do {
            calorieGoal = try await goalRepository.fetchGoal(for: date)
        } catch {
            // Silently fail for goal loading - it's ok if there's no goal set
            calorieGoal = nil
        }
        
        isLoading = false
    }
    
    func deleteFoodItem(by id: UUID) async {
        do {
            try await foodListrepository.deleteFood(id: id)
            await loadFoodItems()
        } catch let error as FoodRepositoryError {
            handleDomainError(error)
        } catch {
            handleError(message: error.localizedDescription)
        }
    }
    
    func updateFoodItem(_ item: FoodItem) async {
        do {
            try await foodListrepository.updateFood(item: item)
        } catch let error as FoodRepositoryError {
            handleDomainError(error)
        } catch {
            handleError(message: error.localizedDescription)
        }
    }
    
    // MARK: - Goal Management
    
    func setCalorieGoal(dailyTarget: Int, for date: Date = Date()) async {
        do {
            try await goalRepository.saveOrUpdateGoal(dailyTarget: dailyTarget, for: date)
            calorieGoal = try await goalRepository.fetchGoal(for: date)
        } catch let error as CalorieGoalRepositoryError {
            handleGoalError(error)
        } catch {
            handleError(message: error.localizedDescription)
        }
    }
    
    func deleteGoal() async {
        guard let goal = calorieGoal else { return }
        
        do {
            try await goalRepository.deleteGoal(id: goal.id)
            calorieGoal = nil
        } catch let error as CalorieGoalRepositoryError {
            handleGoalError(error)
        } catch {
            handleError(message: error.localizedDescription)
        }
    }
    
    // MARK: - Duplicate Handling
    
    func addDuplicateAnyway() async {
        guard let validated = pendingValidatedInput else { return }
        
        do {
            let newItem = FoodItem(
                name: validated.name,
                calories: validated.calories
            )
            try await foodListrepository.createFood(item: newItem)
            await loadFoodItems()
            
            pendingValidatedInput = nil
            duplicateItem = nil
            
        } catch let error as FoodRepositoryError {
            handleDomainError(error)
        } catch {
            handleError(message: error.localizedDescription)
        }
    }
    
    func replaceWithNew() async {
        guard let validated = pendingValidatedInput,
              let oldItem = duplicateItem else { return }
        
        do {
            try await foodListrepository.deleteFood(id: oldItem.id)
            
            let newItem = FoodItem(
                name: validated.name,
                calories: validated.calories
            )
            try await foodListrepository.createFood(item: newItem)
            await loadFoodItems()
            
            pendingValidatedInput = nil
            duplicateItem = nil
            
        } catch let error as FoodRepositoryError {
            handleDomainError(error)
        } catch {
            handleError(message: error.localizedDescription)
        }
    }
    
}

//MARK: - Error Handling

private extension CalorieСalculatorViewModel {
    func handleDomainError(_ error: FoodRepositoryError) {
        errorMessage = error.localizedDescription
        showErrorAlert = true
        print("Domain Error: \(error.userFacingMessage)")
    }
    
    func handleGoalError(_ error: CalorieGoalRepositoryError) {
        errorMessage = error.userFacingMessage
        showErrorAlert = true
        print("Goal Error: \(error.localizedDescription)")
    }
    
    func handleError(message: String) {
        errorMessage = message
        showErrorAlert = true
        print("Unexpected Error: \(message)")
    }
    
    func showDuplicateAlert(for existingItem: FoodItem, newCalories: Int) {
        duplicateItem = existingItem
        duplicateAlertTitle = "Product already added"
        duplicateAlertMessage = """
        "\(existingItem.name)" is already added today with \(existingItem.calories) kcal.
        
        Do you want to add it again with \(newCalories) kcal or replace the existing one?
        """
        showDuplicateAlert = true
    }
}

