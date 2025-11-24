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
    
    //MARK: - Init
    
    init(repository: FoodRepositoryProtocol) {
        self.repository = repository
    }
    
    //MARK: - State
    
    private(set) var items: [FoodItem] = []
    private(set) var isLoading: Bool = false
    private(set) var errorMessage: String? = nil
    
    var showErrorAlert = false
    
    //MARK: - Computed Properties
    
    var totalCalories: Int {
        items.reduce(0) { $0 + $1.calories }
    }
    
    var isEmpty: Bool {
        items.isEmpty && !isLoading
    }
    
    //MARK: - Actions
    
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
    
    func addFoodItem(name: String, calories: Int) async {
        let newItem = FoodItem(name: name, calories: calories)
        do {
            try await repository.createFood(item: newItem)
            await loadFoodItems()
        } catch let error as FoodRepositoryError {
            handleDomainError(error)
        } catch {
            handleError(message: error.localizedDescription)
        }
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
}

