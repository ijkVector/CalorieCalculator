//
//  FoodStore.swift
//  CalorieСalculator
//
//  Created by Иван Дроботов on 11/24/25.
//

import Foundation
import SwiftData

actor FoodStore: FoodStoreProtocol {
    
    //MARK: - Properties
    private let modelContainer: ModelContainer
    
    private lazy var modelContext = ModelContext(modelContainer)
    
    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }
    
    func fetchItems(for date: Date) throws -> [FoodItemDTO] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            throw FoodStoreError.invalidDateRange
        }
        
        let predicate = #Predicate<FoodItemEntity> {
            $0.timestamp >= startOfDay && $0.timestamp < endOfDay
        }
        
        let descriptor = FetchDescriptor<FoodItemEntity>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        
        do {
            return try modelContext.fetch(descriptor).map { toDTO($0) }
        } catch {
            throw FoodStoreError.fetchFailed(error)
        }
    }
    
    func create(item: FoodItemDTO) throws {
        modelContext.insert(item.toEntity())
        do {
            try modelContext.save()
        } catch {
            throw mapSaveError(error, item.id)
        }
    }
    
    func update(item: FoodItemDTO) throws {
        guard let oldItem = try findItem(with: item.id) else {
            throw FoodStoreError.itemNotFound(item.id)
        }
        
        oldItem.name = item.name
        oldItem.calories = item.calories
        oldItem.imageData = item.imageData
        oldItem.timestamp = item.timestamp
        
        do {
            try modelContext.save()
        } catch {
            throw mapSaveError(error, item.id)
        }
    }
    
    func delete(id: UUID) throws {
        guard let item = try findItem(with: id) else {
            throw FoodStoreError.itemNotFound(id)
        }
        
        modelContext.delete(item)
        
        do {
            try modelContext.save()
        } catch {
            throw mapSaveError(error, id)
        }
    }
}

//MARK: - Private Section 

private extension FoodStore {
    func findItem(with id: UUID) throws -> FoodItemEntity? {
        let predicate = #Predicate<FoodItemEntity> { $0.id == id }
        
        var descriptor = FetchDescriptor<FoodItemEntity>(
            predicate: predicate
        )
        descriptor.fetchLimit = 1
        
        do {
            let entities = try modelContext.fetch(descriptor)
            return entities.first
        } catch {
            throw FoodStoreError.fetchFailed(error)
        }
    }
    
    func toDTO(_ entity: FoodItemEntity) -> FoodItemDTO {
        FoodItemDTO(
            id: entity.id,
            name: entity.name,
            calories: entity.calories,
            imageData: entity.imageData,
            timestamp: entity.timestamp
        )
    }
    
    func mapSaveError(_ error: Error, _ itemID: UUID) -> FoodStoreError {
        let nsError = error as NSError
        switch (nsError.domain, nsError.code) {
        case (NSCocoaErrorDomain, 640):
            return .storageFull
        case (NSCocoaErrorDomain, 133021):
            return .duplicateItem(itemID)
        default:
            return .saveFailed(error)
        }
    }
}
