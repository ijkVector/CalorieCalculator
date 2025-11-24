//
//  FoodStoreMock.swift
//  CalorieСalculatorTests
//
//  Created by Иван Дроботов on 11/24/25.
//

import Foundation
@testable import CalorieСalculator

actor FoodStoreMock: FoodStoreProtocol {
    
    // MARK: - Tracking Properties
    
    var fetchItemsCalled = false
    var fetchItemsCallCount = 0
    var fetchItemsLastDate: Date?
    
    var createCalled = false
    var createCallCount = 0
    var createLastItem: FoodItemDTO?
    
    var updateCalled = false
    var updateCallCount = 0
    var updateLastItem: FoodItemDTO?
    
    var deleteCalled = false
    var deleteCallCount = 0
    var deleteLastId: UUID?
    
    // MARK: - Stub Data
    
    var fetchItemsResult: Result<[FoodItemDTO], Error> = .success([])
    var createResult: Result<Void, Error> = .success(())
    var updateResult: Result<Void, Error> = .success(())
    var deleteResult: Result<Void, Error> = .success(())
    
    // MARK: - FoodStoreProtocol Implementation
    
    func fetchItems(for date: Date) throws -> [FoodItemDTO] {
        fetchItemsCalled = true
        fetchItemsCallCount += 1
        fetchItemsLastDate = date
        
        switch fetchItemsResult {
        case .success(let items):
            return items
        case .failure(let error):
            throw error
        }
    }
    
    func create(item: FoodItemDTO) throws {
        createCalled = true
        createCallCount += 1
        createLastItem = item
        
        switch createResult {
        case .success:
            return
        case .failure(let error):
            throw error
        }
    }
    
    func update(item: FoodItemDTO) throws {
        updateCalled = true
        updateCallCount += 1
        updateLastItem = item
        
        switch updateResult {
        case .success:
            return
        case .failure(let error):
            throw error
        }
    }
    
    func delete(id: UUID) throws {
        deleteCalled = true
        deleteCallCount += 1
        deleteLastId = id
        
        switch deleteResult {
        case .success:
            return
        case .failure(let error):
            throw error
        }
    }
    
    // MARK: - Helper Methods
    
    func reset() {
        fetchItemsCalled = false
        fetchItemsCallCount = 0
        fetchItemsLastDate = nil
        
        createCalled = false
        createCallCount = 0
        createLastItem = nil
        
        updateCalled = false
        updateCallCount = 0
        updateLastItem = nil
        
        deleteCalled = false
        deleteCallCount = 0
        deleteLastId = nil
        
        fetchItemsResult = .success([])
        createResult = .success(())
        updateResult = .success(())
        deleteResult = .success(())
    }
    
    func setFetchItemsResult(_ result: Result<[FoodItemDTO], Error>) {
        fetchItemsResult = result
    }
    
    func setCreateResult(_ result: Result<Void, Error>) {
        createResult = result
    }
    
    func setUpdateResult(_ result: Result<Void, Error>) {
        updateResult = result
    }
    
    func setDeleteResult(_ result: Result<Void, Error>) {
        deleteResult = result
    }
}
