//
//  FoodRepositoryTests.swift
//  CalorieСalculatorTests
//
//  Created by Иван Дроботов on 11/24/25.
//

import Foundation
import Testing
@testable import CalorieСalculator

// MARK: - Test Suite

@Suite("FoodRepository Operations with Mocked Store")
struct FoodRepositoryTests {
    
    // MARK: - Properties
    
    let mockStore: FoodStoreMock
    let sut: FoodRepository
    
    // MARK: - Initialization
    
    init() async {
        mockStore = FoodStoreMock()
        sut = FoodRepository(store: mockStore)
    }
    
    // MARK: - Helper Methods
    
    private func createTestFoodItem(
        id: UUID = UUID(),
        name: String = "Test Food",
        calories: Int = 100,
        imageData: Data? = nil,
        timestamp: Date = Date()
    ) -> FoodItem {
        FoodItem(
            id: id,
            name: name,
            calories: calories,
            imageData: imageData,
            timestamp: timestamp
        )
    }
    
    private func createTestDTO(
        id: UUID = UUID(),
        name: String = "Test Food",
        calories: Int = 100,
        imageData: Data? = nil,
        timestamp: Date = Date()
    ) -> FoodItemDTO {
        FoodItemDTO(
            id: id,
            name: name,
            calories: calories,
            imageData: imageData,
            timestamp: timestamp
        )
    }
}

// MARK: - Fetch Tests

extension FoodRepositoryTests {
    
    @Test("Fetch: Successfully fetch and map items")
    func fetchSuccessfullyMapsItems() async throws {
        // Given
        let date = Date()
        let dto1 = createTestDTO(name: "Apple", calories: 52)
        let dto2 = createTestDTO(name: "Banana", calories: 89)
        
        await mockStore.reset()
        await mockStore.setFetchItemsResult(.success([dto1, dto2]))
        
        // When
        let items = try await sut.fetchFoodItems(for: date)
        
        // Then
        #expect(items.count == 2)
        #expect(items[0].name == "Apple")
        #expect(items[0].calories == 52)
        #expect(items[1].name == "Banana")
        #expect(items[1].calories == 89)
        
        // Verify mock was called
        let wasCalled = await mockStore.fetchItemsCalled
        let callCount = await mockStore.fetchItemsCallCount
        let lastDate = await mockStore.fetchItemsLastDate
        
        #expect(wasCalled)
        #expect(callCount == 1)
        #expect(lastDate == date)
    }
    
    @Test("Fetch: Return empty array when store returns empty")
    func fetchReturnsEmptyArray() async throws {
        // Given
        let date = Date()
        await mockStore.reset()
        await mockStore.setFetchItemsResult(.success([]))
        
        // When
        let items = try await sut.fetchFoodItems(for: date)
        
        // Then
        #expect(items.isEmpty)
    }
    
    @Test("Fetch: Map FoodStoreError.fetchFailed to cannotLoadFoods")
    func fetchMapsFetchFailedError() async throws {
        // Given
        let date = Date()
        let underlyingError = NSError(domain: "Test", code: 123)
        await mockStore.reset()
        await mockStore.setFetchItemsResult(.failure(FoodStoreError.fetchFailed(underlyingError)))
        
        // When/Then
        do {
            _ = try await sut.fetchFoodItems(for: date)
            Issue.record("Expected error to be thrown")
        } catch let error as FoodRepositoryError {
            if case .cannotLoadFoods(let reason) = error {
                #expect(reason.contains("Test"))
            } else {
                Issue.record("Expected cannotLoadFoods error, got \(error)")
            }
        }
    }
    
    @Test("Fetch: Map FoodStoreError.invalidDateRange to invalidDate")
    func fetchMapsInvalidDateRangeError() async throws {
        // Given
        let date = Date()
        await mockStore.reset()
        await mockStore.setFetchItemsResult(.failure(FoodStoreError.invalidDateRange))
        
        // When/Then
        do {
            _ = try await sut.fetchFoodItems(for: date)
            Issue.record("Expected error to be thrown")
        } catch let error as FoodRepositoryError {
            if case .invalidDate = error {
                // Success
            } else {
                Issue.record("Expected invalidDate error, got \(error)")
            }
        }
    }
    
    @Test("Fetch: Map unknown error to cannotLoadFoods")
    func fetchMapsUnknownError() async throws {
        // Given
        let date = Date()
        struct UnknownError: Error {}
        await mockStore.reset()
        await mockStore.setFetchItemsResult(.failure(UnknownError()))
        
        // When/Then
        do {
            _ = try await sut.fetchFoodItems(for: date)
            Issue.record("Expected error to be thrown")
        } catch let error as FoodRepositoryError {
            if case .cannotLoadFoods = error {
                // Success
            } else {
                Issue.record("Expected cannotLoadFoods error, got \(error)")
            }
        }
    }
}

// MARK: - Create Tests

extension FoodRepositoryTests {
    
    @Test("Create: Successfully create and map domain to DTO")
    func createSuccessfullyMapsDomainToDTO() async throws {
        // Given
        let foodItem = createTestFoodItem(name: "Pizza", calories: 250)
        await mockStore.reset()
        await mockStore.setCreateResult(.success(()))
        
        // When
        try await sut.createFood(item: foodItem)
        
        // Then
        let wasCalled = await mockStore.createCalled
        let callCount = await mockStore.createCallCount
        let lastItem = await mockStore.createLastItem
        
        #expect(wasCalled)
        #expect(callCount == 1)
        #expect(lastItem?.name == "Pizza")
        #expect(lastItem?.calories == 250)
        #expect(lastItem?.id == foodItem.id)
    }
    
    @Test("Create: Map FoodStoreError.duplicateItem to duplicateFoodEntry")
    func createMapsDuplicateItemError() async throws {
        // Given
        let id = UUID()
        let foodItem = createTestFoodItem(id: id, name: "Duplicate")
        await mockStore.reset()
        await mockStore.setCreateResult(.failure(FoodStoreError.duplicateItem(id)))
        
        // When/Then
        do {
            try await sut.createFood(item: foodItem)
            Issue.record("Expected error to be thrown")
        } catch let error as FoodRepositoryError {
            if case .duplicateFoodEntry(let errorId) = error {
                #expect(errorId == id)
            } else {
                Issue.record("Expected duplicateFoodEntry error, got \(error)")
            }
        }
    }
    
    @Test("Create: Map FoodStoreError.storageFull to deviceStorageExhausted")
    func createMapsStorageFullError() async throws {
        // Given
        let foodItem = createTestFoodItem(name: "Large Item")
        await mockStore.reset()
        await mockStore.setCreateResult(.failure(FoodStoreError.storageFull))
        
        // When/Then
        do {
            try await sut.createFood(item: foodItem)
            Issue.record("Expected error to be thrown")
        } catch let error as FoodRepositoryError {
            if case .deviceStorageExhausted = error {
                // Success
            } else {
                Issue.record("Expected deviceStorageExhausted error, got \(error)")
            }
        }
    }
    
    @Test("Create: Map FoodStoreError.saveFailed to cannotSaveFood")
    func createMapsSaveFailedError() async throws {
        // Given
        let foodItem = createTestFoodItem()
        let underlyingError = NSError(domain: "Save", code: 456)
        await mockStore.reset()
        await mockStore.setCreateResult(.failure(FoodStoreError.saveFailed(underlyingError)))
        
        // When/Then
        do {
            try await sut.createFood(item: foodItem)
            Issue.record("Expected error to be thrown")
        } catch let error as FoodRepositoryError {
            if case .cannotSaveFood(let reason) = error {
                #expect(reason.contains("Save"))
            } else {
                Issue.record("Expected cannotSaveFood error, got \(error)")
            }
        }
    }
    
    @Test("Create: Map unknown error to cannotSaveFood")
    func createMapsUnknownError() async throws {
        // Given
        let foodItem = createTestFoodItem()
        struct UnknownError: Error {}
        await mockStore.reset()
        await mockStore.setCreateResult(.failure(UnknownError()))
        
        // When/Then
        do {
            try await sut.createFood(item: foodItem)
            Issue.record("Expected error to be thrown")
        } catch let error as FoodRepositoryError {
            if case .cannotSaveFood = error {
                // Success
            } else {
                Issue.record("Expected cannotSaveFood error, got \(error)")
            }
        }
    }
    
    @Test("Create: Preserve all fields during mapping")
    func createPreservesAllFields() async throws {
        // Given
        let imageData = Data([0x01, 0x02, 0x03])
        let timestamp = Date()
        let foodItem = createTestFoodItem(
            id: UUID(),
            name: "Full Item",
            calories: 300,
            imageData: imageData,
            timestamp: timestamp
        )
        await mockStore.reset()
        await mockStore.setCreateResult(.success(()))
        
        // When
        try await sut.createFood(item: foodItem)
        
        // Then
        let lastItem = await mockStore.createLastItem
        #expect(lastItem?.id == foodItem.id)
        #expect(lastItem?.name == "Full Item")
        #expect(lastItem?.calories == 300)
        #expect(lastItem?.imageData == imageData)
        #expect(lastItem?.timestamp == timestamp)
    }
}

// MARK: - Update Tests

extension FoodRepositoryTests {
    
    @Test("Update: Successfully update and map domain to DTO")
    func updateSuccessfullyMapsDomainToDTO() async throws {
        // Given
        let foodItem = createTestFoodItem(name: "Updated Pizza", calories: 280)
        await mockStore.reset()
        await mockStore.setUpdateResult(.success(()))
        
        // When
        try await sut.updateFood(item: foodItem)
        
        // Then
        let wasCalled = await mockStore.updateCalled
        let callCount = await mockStore.updateCallCount
        let lastItem = await mockStore.updateLastItem
        
        #expect(wasCalled)
        #expect(callCount == 1)
        #expect(lastItem?.name == "Updated Pizza")
        #expect(lastItem?.calories == 280)
        #expect(lastItem?.id == foodItem.id)
    }
    
    @Test("Update: Map FoodStoreError.itemNotFound to foodItemNotFound")
    func updateMapsItemNotFoundError() async throws {
        // Given
        let id = UUID()
        let foodItem = createTestFoodItem(id: id, name: "Missing")
        await mockStore.reset()
        await mockStore.setUpdateResult(.failure(FoodStoreError.itemNotFound(id)))
        
        // When/Then
        do {
            try await sut.updateFood(item: foodItem)
            Issue.record("Expected error to be thrown")
        } catch let error as FoodRepositoryError {
            if case .foodItemNotFound(let errorId) = error {
                #expect(errorId == id)
            } else {
                Issue.record("Expected foodItemNotFound error, got \(error)")
            }
        }
    }
    
    @Test("Update: Map FoodStoreError.saveFailed to cannotSaveFood")
    func updateMapsSaveFailedError() async throws {
        // Given
        let foodItem = createTestFoodItem()
        let underlyingError = NSError(domain: "Update", code: 789)
        await mockStore.reset()
        await mockStore.setUpdateResult(.failure(FoodStoreError.saveFailed(underlyingError)))
        
        // When/Then
        do {
            try await sut.updateFood(item: foodItem)
            Issue.record("Expected error to be thrown")
        } catch let error as FoodRepositoryError {
            if case .cannotSaveFood(let reason) = error {
                #expect(reason.contains("Update"))
            } else {
                Issue.record("Expected cannotSaveFood error, got \(error)")
            }
        }
    }
    
    @Test("Update: Map unknown error to cannotSaveFood")
    func updateMapsUnknownError() async throws {
        // Given
        let foodItem = createTestFoodItem()
        struct UnknownError: Error {}
        await mockStore.reset()
        await mockStore.setUpdateResult(.failure(UnknownError()))
        
        // When/Then
        do {
            try await sut.updateFood(item: foodItem)
            Issue.record("Expected error to be thrown")
        } catch let error as FoodRepositoryError {
            if case .cannotSaveFood = error {
                // Success
            } else {
                Issue.record("Expected cannotSaveFood error, got \(error)")
            }
        }
    }
}

// MARK: - Delete Tests

extension FoodRepositoryTests {
    
    @Test("Delete: Successfully delete by ID")
    func deleteSuccessfullyDeletesById() async throws {
        // Given
        let id = UUID()
        await mockStore.reset()
        await mockStore.setDeleteResult(.success(()))
        
        // When
        try await sut.deleteFood(id: id)
        
        // Then
        let wasCalled = await mockStore.deleteCalled
        let callCount = await mockStore.deleteCallCount
        let lastId = await mockStore.deleteLastId
        
        #expect(wasCalled)
        #expect(callCount == 1)
        #expect(lastId == id)
    }
    
    @Test("Delete: Map FoodStoreError.itemNotFound to foodItemNotFound")
    func deleteMapsMapsItemNotFoundError() async throws {
        // Given
        let id = UUID()
        await mockStore.reset()
        await mockStore.setDeleteResult(.failure(FoodStoreError.itemNotFound(id)))
        
        // When/Then
        do {
            try await sut.deleteFood(id: id)
            Issue.record("Expected error to be thrown")
        } catch let error as FoodRepositoryError {
            if case .foodItemNotFound(let errorId) = error {
                #expect(errorId == id)
            } else {
                Issue.record("Expected foodItemNotFound error, got \(error)")
            }
        }
    }
    
    @Test("Delete: Map FoodStoreError.saveFailed to cannotSaveFood")
    func deleteMapsSaveFailedError() async throws {
        // Given
        let id = UUID()
        let underlyingError = NSError(domain: "Delete", code: 999)
        await mockStore.reset()
        await mockStore.setDeleteResult(.failure(FoodStoreError.saveFailed(underlyingError)))
        
        // When/Then
        do {
            try await sut.deleteFood(id: id)
            Issue.record("Expected error to be thrown")
        } catch let error as FoodRepositoryError {
            if case .cannotSaveFood(let reason) = error {
                #expect(reason.contains("Delete"))
            } else {
                Issue.record("Expected cannotSaveFood error, got \(error)")
            }
        }
    }
    
    @Test("Delete: Map unknown error to cannotSaveFood")
    func deleteMapsUnknownError() async throws {
        // Given
        let id = UUID()
        struct UnknownError: Error {}
        await mockStore.reset()
        await mockStore.setDeleteResult(.failure(UnknownError()))
        
        // When/Then
        do {
            try await sut.deleteFood(id: id)
            Issue.record("Expected error to be thrown")
        } catch let error as FoodRepositoryError {
            if case .cannotSaveFood = error {
                // Success
            } else {
                Issue.record("Expected cannotSaveFood error, got \(error)")
            }
        }
    }
}

// MARK: - Integration Tests

extension FoodRepositoryTests {
    
    @Test("Integration: Full CRUD lifecycle with mock")
    func fullCRUDLifecycleWithMock() async throws {
        // Given
        let date = Date()
        let foodItem = createTestFoodItem(name: "Integration Test", calories: 150)
        
        // Create
        await mockStore.reset()
        await mockStore.setCreateResult(.success(()))
        try await sut.createFood(item: foodItem)
        
        let createWasCalled = await mockStore.createCalled
        #expect(createWasCalled)
        
        // Fetch
        let dto = createTestDTO(
            id: foodItem.id,
            name: "Integration Test",
            calories: 150,
            timestamp: date
        )
        await mockStore.reset()
        await mockStore.setFetchItemsResult(.success([dto]))
        let items = try await sut.fetchFoodItems(for: date)
        #expect(items.count == 1)
        #expect(items.first?.name == "Integration Test")
        
        // Update
        let updatedItem = FoodItem(
            id: foodItem.id,
            name: "Updated Integration",
            calories: 200,
            timestamp: date
        )
        await mockStore.reset()
        await mockStore.setUpdateResult(.success(()))
        try await sut.updateFood(item: updatedItem)
        
        let updateWasCalled = await mockStore.updateCalled
        #expect(updateWasCalled)
        
        // Delete
        await mockStore.reset()
        await mockStore.setDeleteResult(.success(()))
        try await sut.deleteFood(id: foodItem.id)
        
        let deleteWasCalled = await mockStore.deleteCalled
        #expect(deleteWasCalled)
    }
    
    @Test("Integration: Verify all error mappings", arguments: [
        ("itemNotFound", FoodStoreError.itemNotFound(UUID())),
        ("storageFull", FoodStoreError.storageFull),
        ("duplicateItem", FoodStoreError.duplicateItem(UUID())),
        ("invalidDateRange", FoodStoreError.invalidDateRange)
    ])
    func verifyAllErrorMappings(name: String, storeError: FoodStoreError) async throws {
        // Given
        let date = Date()
        await mockStore.reset()
        await mockStore.setFetchItemsResult(.failure(storeError))
        
        // When/Then
        do {
            _ = try await sut.fetchFoodItems(for: date)
            Issue.record("Expected error to be thrown for \(name)")
        } catch is FoodRepositoryError {
            // Success - error was properly mapped
        } catch {
            Issue.record("Expected FoodRepositoryError, got \(error)")
        }
    }
}

