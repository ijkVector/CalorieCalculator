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
    
    private let repository: FoodRepositoryProtocol
    private let inputValidator: FoodInputValidating
    private let duplicateChecker: FoodDuplicateChecking
    
    //MARK: - Init
    
    init(
        repository: FoodRepositoryProtocol,
        inputValidator: FoodInputValidating,
        duplicateChecker: FoodDuplicateChecking
    ) {
        self.repository = repository
        self.inputValidator = inputValidator
        self.duplicateChecker = duplicateChecker
    }
    
    //MARK: - State
    
    private(set) var items: [FoodItem] = []
    private(set) var isLoading: Bool = false
    private(set) var errorMessage: String? = nil
    
    var showErrorAlert = false
    
    // Alert state для дубликатов
    var showDuplicateAlert = false
    var duplicateAlertTitle = ""
    var duplicateAlertMessage = ""
    var duplicateItem: FoodItem?
    
    private var pendingValidatedInput: ValidatedFoodInput?
    
    //MARK: - Computed Properties
    
    var totalCalories: Int {
        items.reduce(0) { $0 + $1.calories }
    }
    
    var isEmpty: Bool {
        items.isEmpty && !isLoading
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
                try await repository.createFood(item: newItem)
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
        do {
            items = try await repository.fetchFoodItems(for: date)
        } catch let error as FoodRepositoryError {
            handleDomainError(error)
        } catch {
            handleError(message: error.localizedDescription)
        }
        isLoading = false
    }
    
    func deleteFoodItem(by id: UUID) async {
        do {
            try await repository.deleteFood(id: id)
            await loadFoodItems()
        } catch let error as FoodRepositoryError {
            handleDomainError(error)
        } catch {
            handleError(message: error.localizedDescription)
        }
    }
    
    func updateFoodItem(_ item: FoodItem) async {
        do {
            try await repository.updateFood(item: item)
        } catch let error as FoodRepositoryError {
            handleDomainError(error)
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
            try await repository.createFood(item: newItem)
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
            try await repository.deleteFood(id: oldItem.id)
            
            let newItem = FoodItem(
                name: validated.name,
                calories: validated.calories
            )
            try await repository.createFood(item: newItem)
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

