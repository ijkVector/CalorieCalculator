//
//  FoodStoreTests.swift
//  CalorieСalculatorTests
//
//  Created by Иван Дроботов on 11/24/25.
//

import Foundation
import Testing
import SwiftData
@testable import CalorieСalculator

// MARK: - Test Suite

@Suite("FoodStore CRUD Operations")
@MainActor
struct FoodStoreTests {
    
    // MARK: - Properties
    
    let sut: FoodStore
    let modelContainer: ModelContainer
    
    // MARK: - Initialization
    
    init() throws {
        // Create in-memory container for isolated testing
        let schema = Schema([FoodItemEntity.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: [config])
        sut = FoodStore(modelContainer: modelContainer)
    }
    
    // MARK: - Helper Methods
    
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
    
    private func makeDate(
        year: Int = 2024,
        month: Int = 11,
        day: Int = 24,
        hour: Int = 12,
        minute: Int = 0
    ) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        components.timeZone = TimeZone.current
        return Calendar.current.date(from: components)!
    }
}

// MARK: - CREATE Tests

extension FoodStoreTests {
    
    @Test("Create: Successfully insert item")
    func createSuccessfullyInsertsItem() async throws {
        // Given
        let testItem = createTestDTO(name: "Apple", calories: 52)
        
        // When
        try await sut.create(item: testItem)
        
        // Then
        let fetchedItems = try await sut.fetchItems(for: testItem.timestamp)
        #expect(fetchedItems.count == 1)
        #expect(fetchedItems.first?.name == "Apple")
        #expect(fetchedItems.first?.calories == 52)
        #expect(fetchedItems.first?.id == testItem.id)
    }
    
    @Test("Create: Store image data")
    func createStoresImageData() async throws {
        // Given
        let imageData = Data([0x01, 0x02, 0x03])
        let testItem = createTestDTO(name: "Pizza", calories: 250, imageData: imageData)
        
        // When
        try await sut.create(item: testItem)
        
        // Then
        let fetchedItems = try await sut.fetchItems(for: testItem.timestamp)
        #expect(fetchedItems.first?.imageData == imageData)
    }
    
    @Test("Create: Handle nil image data")
    func createHandlesNilImageData() async throws {
        // Given
        let testItem = createTestDTO(name: "Salad", calories: 150, imageData: nil)
        
        // When
        try await sut.create(item: testItem)
        
        // Then
        let fetchedItems = try await sut.fetchItems(for: testItem.timestamp)
        #expect(fetchedItems.first?.imageData == nil)
    }
    
    @Test("Create: Handle edge cases", arguments: [
        ("Water", 0),
        ("Negative Food", -100),
        ("", 50),
        ("Food 🍕🍔 & More! @#$%", 200)
    ])
    func createHandlesEdgeCases(name: String, calories: Int) async throws {
        // Given
        let testItem = createTestDTO(name: name, calories: calories)
        
        // When
        try await sut.create(item: testItem)
        
        // Then
        let fetchedItems = try await sut.fetchItems(for: testItem.timestamp)
        #expect(fetchedItems.first?.name == name)
        #expect(fetchedItems.first?.calories == calories)
    }
    
    @Test("Create: Handle very long name")
    func createHandlesLongName() async throws {
        // Given
        let longName = String(repeating: "A", count: 1000)
        let testItem = createTestDTO(name: longName, calories: 100)
        
        // When
        try await sut.create(item: testItem)
        
        // Then
        let fetchedItems = try await sut.fetchItems(for: testItem.timestamp)
        #expect(fetchedItems.first?.name == longName)
    }
    
    @Test("Create: Handle multiple items")
    func createHandlesMultipleItems() async throws {
        // Given
        let today = Date()
        let items = [
            createTestDTO(name: "Apple", calories: 52, timestamp: today),
            createTestDTO(name: "Banana", calories: 89, timestamp: today),
            createTestDTO(name: "Orange", calories: 47, timestamp: today)
        ]
        
        // When
        for item in items {
            try await sut.create(item: item)
        }
        
        // Then
        let fetchedItems = try await sut.fetchItems(for: today)
        #expect(fetchedItems.count == 3)
    }
}

// MARK: - FETCH Tests

extension FoodStoreTests {
    
    @Test("Fetch: Return empty array when no items")
    func fetchReturnsEmptyArrayWhenNoItems() async throws {
        // Given
        let today = Date()
        
        // When
        let items = try await sut.fetchItems(for: today)
        
        // Then
        #expect(items.isEmpty)
    }
    
    @Test("Fetch: Return only items for specific date")
    func fetchReturnsOnlyItemsForSpecificDate() async throws {
        // Given
        let targetDate = makeDate(day: 24, hour: 14)
        let otherDate = makeDate(day: 25, hour: 10)
        
        let itemToday = createTestDTO(name: "Today", calories: 100, timestamp: targetDate)
        let itemTomorrow = createTestDTO(name: "Tomorrow", calories: 200, timestamp: otherDate)
        
        try await sut.create(item: itemToday)
        try await sut.create(item: itemTomorrow)
        
        // When
        let items = try await sut.fetchItems(for: targetDate)
        
        // Then
        #expect(items.count == 1)
        #expect(items.first?.name == "Today")
    }
    
    @Test("Fetch: Include all items from start to end of day")
    func fetchIncludesAllItemsFromStartToEndOfDay() async throws {
        // Given
        let date = makeDate(day: 24)
        let morning = makeDate(day: 24, hour: 6, minute: 0)
        let noon = makeDate(day: 24, hour: 12, minute: 30)
        let evening = makeDate(day: 24, hour: 23, minute: 59)
        
        let items = [
            createTestDTO(name: "Breakfast", calories: 300, timestamp: morning),
            createTestDTO(name: "Lunch", calories: 500, timestamp: noon),
            createTestDTO(name: "Dinner", calories: 600, timestamp: evening)
        ]
        
        for item in items {
            try await sut.create(item: item)
        }
        
        // When
        let fetchedItems = try await sut.fetchItems(for: date)
        
        // Then
        #expect(fetchedItems.count == 3)
    }
    
    @Test("Fetch: Not include items from previous day")
    func fetchNotIncludesItemsFromPreviousDay() async throws {
        // Given
        let today = makeDate(day: 24, hour: 1, minute: 0)
        let yesterday = makeDate(day: 23, hour: 23, minute: 59)
        
        let itemYesterday = createTestDTO(name: "Yesterday", calories: 100, timestamp: yesterday)
        let itemToday = createTestDTO(name: "Today", calories: 200, timestamp: today)
        
        try await sut.create(item: itemYesterday)
        try await sut.create(item: itemToday)
        
        // When
        let items = try await sut.fetchItems(for: today)
        
        // Then
        #expect(items.count == 1)
        #expect(items.first?.name == "Today")
    }
    
    @Test("Fetch: Not include items from next day")
    func fetchNotIncludesItemsFromNextDay() async throws {
        // Given
        let today = makeDate(day: 24, hour: 23, minute: 59)
        let tomorrow = makeDate(day: 25, hour: 0, minute: 0)
        
        let itemToday = createTestDTO(name: "Today", calories: 100, timestamp: today)
        let itemTomorrow = createTestDTO(name: "Tomorrow", calories: 200, timestamp: tomorrow)
        
        try await sut.create(item: itemToday)
        try await sut.create(item: itemTomorrow)
        
        // When
        let items = try await sut.fetchItems(for: today)
        
        // Then
        #expect(items.count == 1)
        #expect(items.first?.name == "Today")
    }
    
    @Test("Fetch: Return items sorted by timestamp descending")
    func fetchReturnsSortedItems() async throws {
        // Given
        let date = makeDate(day: 24)
        let time1 = makeDate(day: 24, hour: 8, minute: 0)
        let time2 = makeDate(day: 24, hour: 12, minute: 0)
        let time3 = makeDate(day: 24, hour: 18, minute: 0)
        
        // Insert in random order
        try await sut.create(item: createTestDTO(name: "Second", calories: 200, timestamp: time2))
        try await sut.create(item: createTestDTO(name: "Third", calories: 300, timestamp: time3))
        try await sut.create(item: createTestDTO(name: "First", calories: 100, timestamp: time1))
        
        // When
        let items = try await sut.fetchItems(for: date)
        
        // Then
        #expect(items.count == 3)
        #expect(items[0].name == "Third")  // Most recent first
        #expect(items[1].name == "Second")
        #expect(items[2].name == "First")
    }
    
    @Test("Fetch: Handle future and past dates", arguments: [
        (2025, 12, 31),
        (2020, 1, 1)
    ])
    func fetchHandlesFutureAndPastDates(year: Int, month: Int, day: Int) async throws {
        // Given
        let date = makeDate(year: year, month: month, day: day)
        
        // When
        let items = try await sut.fetchItems(for: date)
        
        // Then
        #expect(items.isEmpty)
    }
}

// MARK: - UPDATE Tests

extension FoodStoreTests {
    
    @Test("Update: Successfully update all fields")
    func updateSuccessfullyUpdatesAllFields() async throws {
        // Given
        let originalItem = createTestDTO(name: "Original", calories: 100)
        try await sut.create(item: originalItem)
        
        let newImageData = Data([0xFF, 0xEE])
        let updatedItem = FoodItemDTO(
            id: originalItem.id,
            name: "Updated",
            calories: 200,
            imageData: newImageData,
            timestamp: originalItem.timestamp
        )
        
        // When
        try await sut.update(item: updatedItem)
        
        // Then
        let items = try await sut.fetchItems(for: originalItem.timestamp)
        #expect(items.count == 1)
        #expect(items.first?.name == "Updated")
        #expect(items.first?.calories == 200)
        #expect(items.first?.imageData == newImageData)
    }
    
    @Test("Update: Throw error when item not found")
    func updateThrowsErrorWhenItemNotFound() async throws {
        // Given
        let nonExistentItem = createTestDTO(id: UUID(), name: "Non-existent", calories: 100)
        
        // When/Then
        await #expect(throws: FoodStoreError.self) {
            try await sut.update(item: nonExistentItem)
        }
    }
    
    @Test("Update: Clear image data when set to nil")
    func updateClearsImageDataWhenSetToNil() async throws {
        // Given
        let originalData = Data([0x01, 0x02])
        let originalItem = createTestDTO(name: "With Image", calories: 100, imageData: originalData)
        try await sut.create(item: originalItem)
        
        let updatedItem = FoodItemDTO(
            id: originalItem.id,
            name: "Without Image",
            calories: 100,
            imageData: nil,
            timestamp: originalItem.timestamp
        )
        
        // When
        try await sut.update(item: updatedItem)
        
        // Then
        let items = try await sut.fetchItems(for: originalItem.timestamp)
        #expect(items.first?.imageData == nil)
    }
    
    @Test("Update: Update timestamp")
    func updateUpdatesTimestamp() async throws {
        // Given
        let originalDate = makeDate(day: 24, hour: 10)
        let newDate = makeDate(day: 24, hour: 15)
        let originalItem = createTestDTO(name: "Item", calories: 100, timestamp: originalDate)
        try await sut.create(item: originalItem)
        
        let updatedItem = FoodItemDTO(
            id: originalItem.id,
            name: "Item",
            calories: 100,
            imageData: nil,
            timestamp: newDate
        )
        
        // When
        try await sut.update(item: updatedItem)
        
        // Then
        let items = try await sut.fetchItems(for: newDate)
        if let timestamp = items.first?.timestamp.timeIntervalSince1970 {
            #expect(abs(timestamp - newDate.timeIntervalSince1970) < 1.0)
        } else {
            Issue.record("Expected timestamp to exist")
        }
    }
    
    @Test("Update: Not affect other items")
    func updateNotAffectsOtherItems() async throws {
        // Given
        let date = Date()
        let item1 = createTestDTO(name: "Item 1", calories: 100, timestamp: date)
        let item2 = createTestDTO(name: "Item 2", calories: 200, timestamp: date)
        
        try await sut.create(item: item1)
        try await sut.create(item: item2)
        
        let updatedItem1 = FoodItemDTO(
            id: item1.id,
            name: "Updated Item 1",
            calories: 150,
            imageData: nil,
            timestamp: date
        )
        
        // When
        try await sut.update(item: updatedItem1)
        
        // Then
        let items = try await sut.fetchItems(for: date)
        #expect(items.count == 2)
        
        let unchangedItem = items.first { $0.id == item2.id }
        #expect(unchangedItem?.name == "Item 2")
        #expect(unchangedItem?.calories == 200)
    }
}

// MARK: - DELETE Tests

extension FoodStoreTests {
    
    @Test("Delete: Successfully remove item")
    func deleteSuccessfullyRemovesItem() async throws {
        // Given
        let item = createTestDTO(name: "To Delete", calories: 100)
        try await sut.create(item: item)
        
        // Verify item exists
        var items = try await sut.fetchItems(for: item.timestamp)
        #expect(items.count == 1)
        
        // When
        try await sut.delete(id: item.id)
        
        // Then
        items = try await sut.fetchItems(for: item.timestamp)
        #expect(items.isEmpty)
    }
    
    @Test("Delete: Throw error when item not found")
    func deleteThrowsErrorWhenItemNotFound() async throws {
        // Given
        let nonExistentId = UUID()
        
        // When/Then
        await #expect(throws: FoodStoreError.self) {
            try await sut.delete(id: nonExistentId)
        }
    }
    
    @Test("Delete: Not affect other items")
    func deleteNotAffectsOtherItems() async throws {
        // Given
        let date = Date()
        let item1 = createTestDTO(name: "Keep", calories: 100, timestamp: date)
        let item2 = createTestDTO(name: "Delete", calories: 200, timestamp: date)
        let item3 = createTestDTO(name: "Keep Too", calories: 300, timestamp: date)
        
        try await sut.create(item: item1)
        try await sut.create(item: item2)
        try await sut.create(item: item3)
        
        // When
        try await sut.delete(id: item2.id)
        
        // Then
        let items = try await sut.fetchItems(for: date)
        #expect(items.count == 2)
        #expect(items.contains { $0.id == item1.id })
        #expect(items.contains { $0.id == item3.id })
        #expect(!items.contains { $0.id == item2.id })
    }
    
    @Test("Delete: Handle multiple deletions")
    func deleteHandlesMultipleDeletions() async throws {
        // Given
        let date = Date()
        let items = [
            createTestDTO(name: "Item 1", calories: 100, timestamp: date),
            createTestDTO(name: "Item 2", calories: 200, timestamp: date),
            createTestDTO(name: "Item 3", calories: 300, timestamp: date)
        ]
        
        for item in items {
            try await sut.create(item: item)
        }
        
        // When
        try await sut.delete(id: items[0].id)
        try await sut.delete(id: items[2].id)
        
        // Then
        let remainingItems = try await sut.fetchItems(for: date)
        #expect(remainingItems.count == 1)
        #expect(remainingItems.first?.id == items[1].id)
    }
}

// MARK: - Integration & Edge Cases Tests

extension FoodStoreTests {
    
    @Test("Integration: Multiple different dates maintain separate data")
    func multipleDifferentDatesMaintainSeparateData() async throws {
        // Given
        let day1 = makeDate(day: 20)
        let day2 = makeDate(day: 21)
        let day3 = makeDate(day: 22)
        
        try await sut.create(item: createTestDTO(name: "Day 1 Item", calories: 100, timestamp: day1))
        try await sut.create(item: createTestDTO(name: "Day 2 Item", calories: 200, timestamp: day2))
        try await sut.create(item: createTestDTO(name: "Day 3 Item", calories: 300, timestamp: day3))
        
        // When/Then
        let day1Items = try await sut.fetchItems(for: day1)
        let day2Items = try await sut.fetchItems(for: day2)
        let day3Items = try await sut.fetchItems(for: day3)
        
        #expect(day1Items.count == 1)
        #expect(day2Items.count == 1)
        #expect(day3Items.count == 1)
        
        #expect(day1Items.first?.name == "Day 1 Item")
        #expect(day2Items.first?.name == "Day 2 Item")
        #expect(day3Items.first?.name == "Day 3 Item")
    }
    
    @Test("Integration: Full CRUD lifecycle")
    func fullCRUDLifecycle() async throws {
        // Given
        let date = Date()
        
        // Create
        let item = createTestDTO(name: "Original", calories: 100, timestamp: date)
        try await sut.create(item: item)
        
        var items = try await sut.fetchItems(for: date)
        #expect(items.count == 1)
        #expect(items.first?.name == "Original")
        
        // Update
        let updatedItem = FoodItemDTO(
            id: item.id,
            name: "Updated",
            calories: 200,
            imageData: nil,
            timestamp: date
        )
        try await sut.update(item: updatedItem)
        
        items = try await sut.fetchItems(for: date)
        #expect(items.first?.name == "Updated")
        #expect(items.first?.calories == 200)
        
        // Delete
        try await sut.delete(id: item.id)
        
        items = try await sut.fetchItems(for: date)
        #expect(items.isEmpty)
    }
    
    @Test("Edge: Items with same name distinguished by ID")
    func itemsWithSameNameDistinguishedByID() async throws {
        // Given
        let date = Date()
        let sameName = "Apple"
        
        let item1 = createTestDTO(id: UUID(), name: sameName, calories: 50, timestamp: date)
        let item2 = createTestDTO(id: UUID(), name: sameName, calories: 52, timestamp: date)
        
        try await sut.create(item: item1)
        try await sut.create(item: item2)
        
        // When
        let items = try await sut.fetchItems(for: date)
        
        // Then
        #expect(items.count == 2)
        #expect(items[0].id != items[1].id)
    }
    
    @Test("Edge: Large image data stored and retrieved")
    func largeImageDataStoredAndRetrieved() async throws {
        // Given
        let largeImageData = Data(repeating: 0xFF, count: 1024 * 1024) // 1MB
        let item = createTestDTO(name: "Large Image", calories: 100, imageData: largeImageData)
        
        // When
        try await sut.create(item: item)
        
        // Then
        let items = try await sut.fetchItems(for: item.timestamp)
        #expect(items.first?.imageData?.count == largeImageData.count)
    }
    
    @Test("Edge: Unicode characters handled correctly")
    func unicodeCharactersHandledCorrectly() async throws {
        // Given
        let unicodeName = "🍎 Яблоко アップル 苹果"
        let item = createTestDTO(name: unicodeName, calories: 52)
        
        // When
        try await sut.create(item: item)
        
        // Then
        let items = try await sut.fetchItems(for: item.timestamp)
        #expect(items.first?.name == unicodeName)
    }
    
    @Test("Edge: Boundary calories stored", arguments: [
        Int.max,
        Int.min
    ])
    func boundaryCaloriesStored(calories: Int) async throws {
        // Given
        let date = Date()
        let item = createTestDTO(name: "Boundary Calories", calories: calories, timestamp: date)
        
        // When
        try await sut.create(item: item)
        
        // Then
        let items = try await sut.fetchItems(for: date)
        #expect(items.contains { $0.calories == calories })
    }
}

