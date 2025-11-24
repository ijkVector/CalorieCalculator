//
//  FoodRepository.swift
//  CalorieСalculator
//
//  Created by Иван Дроботов on 11/23/25.
//

import Foundation
import SwiftData

actor FoodRepository: FoodRepositoryProtocol {
    private let store: FoodStoreProtocol
    
    init(store: FoodStoreProtocol) {
        self.store = store
    }
    
    //MARK: - FoodRepositoryProtocol Implementation
    
    func fetchFoodItems(for date: Date) async throws -> [FoodItem] {
        do {
            let dtos = try await store.fetchItems(for: date)
            return dtos.map { FoodItem(from: $0) }
        } catch let error as FoodStoreError {
            throw mapStoreErrorToDomain(error)
        } catch {
            throw FoodRepositoryError.cannotLoadFoods(reason: error.localizedDescription)
        }
    }
    
    func createFood(item: FoodItem) async throws {
        let dto = FoodItemDTO(from: item)
        
        do {
            try await store.create(item: dto)
        } catch let error as FoodStoreError {
            throw mapStoreErrorToDomain(error)
        } catch {
            throw FoodRepositoryError.cannotSaveFood(reason: error.localizedDescription)
        }
    }
    
    func updateFood(item: FoodItem) async throws {
        let dto = FoodItemDTO(from: item)
        do {
            try await store.update(item: dto)
        } catch let error as FoodStoreError {
            throw mapStoreErrorToDomain(error)
        } catch {
            throw FoodRepositoryError.cannotSaveFood(reason: error.localizedDescription)
        }
    }
    
    func deleteFood(id: UUID) async throws {
        do {
            try await store.delete(id: id)
        } catch let error as FoodStoreError {
            throw mapStoreErrorToDomain(error)
        } catch {
            throw FoodRepositoryError.cannotSaveFood(reason: error.localizedDescription)
        }
    }
}

//MARK: - Maping Errors

private extension FoodRepository {
    private func mapStoreErrorToDomain(_ error: FoodStoreError) -> FoodRepositoryError {
        switch error {
        case .itemNotFound(let id):
            return .foodItemNotFound(id)
        case .storageFull:
            return .deviceStorageExhausted
        case .duplicateItem(let id):
            return .duplicateFoodEntry(id)
        case .invalidDateRange:
            return .invalidDate
        case .saveFailed(let underlyingError):
            return .cannotSaveFood(reason: underlyingError.localizedDescription)
        case .fetchFailed(let underlyingError):
            return .cannotLoadFoods(reason: underlyingError.localizedDescription)
        }
    }
}
