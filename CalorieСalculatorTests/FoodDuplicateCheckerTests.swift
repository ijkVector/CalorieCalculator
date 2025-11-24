//
//  FoodDuplicateCheckerTests.swift
//  CalorieСalculatorTests
//
//  Created by Иван Дроботовccff on 11/24/25.
//

import Testing
import Foundation
@testable import CalorieСalculator

// MARK: - Test Suite

@Suite("FoodDuplicateChecker Tests")
struct FoodDuplicateCheckerTests {
    
    // MARK: - Basic Tests
    
    @Test("Unique name returns .unique")
    func uniqueNameReturnsUnique() {
        // Arrange
        let existingItems = [FoodItem(name: "Apple", calories: 52)]
        let sut = FoodDuplicateChecker()
        
        // Act
        let result = sut.checkForDuplicate(name: "Banana", in: existingItems)
        
        // Assert
        #expect(result == .unique)
    }
    
    @Test("Exact match returns .duplicate")
    func exactMatchReturnsDuplicate() {
        // Arrange
        let existingItem = FoodItem(name: "Apple", calories: 52)
        let existingItems = [existingItem]
        let sut = FoodDuplicateChecker()
        
        // Act
        let result = sut.checkForDuplicate(name: "Apple", in: existingItems)
        
        // Assert
        guard case .duplicate(let found) = result else {
            Issue.record("Expected duplicate, got unique")
            return
        }
        #expect(found.name == existingItem.name)
        #expect(found.calories == existingItem.calories)
    }
    
    // MARK: - Case Sensitivity Tests
    
    @Test("Case insensitive match returns .duplicate")
    func caseInsensitiveMatchReturnsDuplicate() {
        // Arrange
        let existingItem = FoodItem(name: "Apple", calories: 52)
        let existingItems = [existingItem]
        let sut = FoodDuplicateChecker()
        
        // Act - разный регистр
        let result = sut.checkForDuplicate(name: "APPLE", in: existingItems)
        
        // Assert
        guard case .duplicate(let found) = result else {
            Issue.record("Expected duplicate with case insensitive match")
            return
        }
        #expect(found.name == existingItem.name)
    }
    
    @Test("Mixed case match returns .duplicate")
    func mixedCaseMatchReturnsDuplicate() {
        // Arrange
        let existingItem = FoodItem(name: "Green Apple", calories: 52)
        let existingItems = [existingItem]
        let sut = FoodDuplicateChecker()
        
        // Act
        let result = sut.checkForDuplicate(name: "gReEn ApPlE", in: existingItems)
        
        // Assert
        guard case .duplicate = result else {
            Issue.record("Expected duplicate with mixed case")
            return
        }
    }
    
    // MARK: - Whitespace Tests
    
    @Test("Whitespace trimming matches")
    func whitespaceTrimming() {
        // Arrange
        let existingItem = FoodItem(name: "Apple", calories: 52)
        let existingItems = [existingItem]
        let sut = FoodDuplicateChecker()
        
        // Act - пробелы в начале и конце
        let result = sut.checkForDuplicate(name: "  Apple  ", in: existingItems)
        
        // Assert
        guard case .duplicate = result else {
            Issue.record("Expected duplicate with whitespace normalization")
            return
        }
    }
    
    @Test("Leading whitespace matches")
    func leadingWhitespaceMatches() {
        // Arrange
        let existingItem = FoodItem(name: "Banana", calories: 89)
        let existingItems = [existingItem]
        let sut = FoodDuplicateChecker()
        
        // Act
        let result = sut.checkForDuplicate(name: "   Banana", in: existingItems)
        
        // Assert
        guard case .duplicate = result else {
            Issue.record("Expected duplicate with leading whitespace")
            return
        }
    }
    
    @Test("Trailing whitespace matches")
    func trailingWhitespaceMatches() {
        // Arrange
        let existingItem = FoodItem(name: "Orange", calories: 47)
        let existingItems = [existingItem]
        let sut = FoodDuplicateChecker()
        
        // Act
        let result = sut.checkForDuplicate(name: "Orange   ", in: existingItems)
        
        // Assert
        guard case .duplicate = result else {
            Issue.record("Expected duplicate with trailing whitespace")
            return
        }
    }
    
    // MARK: - Multiple Items Tests
    
    @Test("Multiple items checks all")
    func multipleItemsChecksAll() {
        // Arrange
        let items = [
            FoodItem(name: "Apple", calories: 52),
            FoodItem(name: "Banana", calories: 89),
            FoodItem(name: "Orange", calories: 47)
        ]
        let sut = FoodDuplicateChecker()
        
        // Act - проверяем второй элемент
        let result = sut.checkForDuplicate(name: "banana", in: items)
        
        // Assert
        guard case .duplicate(let found) = result else {
            Issue.record("Expected to find Banana in list")
            return
        }
        #expect(found.name == "Banana")
    }
    
    @Test("Finds first match in multiple items")
    func findsFirstMatch() {
        // Arrange
        let item1 = FoodItem(name: "Apple", calories: 52)
        let item2 = FoodItem(name: "Apple", calories: 100)
        let existingItems = [item1, item2]
        let sut = FoodDuplicateChecker()
        
        // Act
        let result = sut.checkForDuplicate(name: "Apple", in: existingItems)
        
        // Assert
        guard case .duplicate(let found) = result else {
            Issue.record("Expected to find duplicate")
            return
        }
        // Должен найти первый
        #expect(found.id == item1.id)
    }
    
    // MARK: - Edge Cases
    
    @Test("Empty array returns .unique")
    func emptyArrayReturnsUnique() {
        // Arrange
        let existingItems: [FoodItem] = []
        let sut = FoodDuplicateChecker()
        
        // Act
        let result = sut.checkForDuplicate(name: "Apple", in: existingItems)
        
        // Assert
        #expect(result == .unique)
    }
    
    @Test("Empty string check returns .unique")
    func emptyStringReturnsUnique() {
        // Arrange
        let existingItems = [FoodItem(name: "Apple", calories: 52)]
        let sut = FoodDuplicateChecker()
        
        // Act
        let result = sut.checkForDuplicate(name: "", in: existingItems)
        
        // Assert
        #expect(result == .unique)
    }
    
    @Test("Whitespace only string returns .unique")
    func whitespaceOnlyReturnsUnique() {
        // Arrange
        let existingItems = [FoodItem(name: "Apple", calories: 52)]
        let sut = FoodDuplicateChecker()
        
        // Act
        let result = sut.checkForDuplicate(name: "   ", in: existingItems)
        
        // Assert
        #expect(result == .unique)
    }
    
    // MARK: - Unicode and Special Characters
    
    @Test("Unicode characters work correctly")
    func unicodeCharactersWork() {
        // Arrange
        let existingItem = FoodItem(name: "Суши Ролл", calories: 280)
        let existingItems = [existingItem]
        let sut = FoodDuplicateChecker()
        
        // Act
        let result = sut.checkForDuplicate(name: "суши ролл", in: existingItems)
        
        // Assert
        guard case .duplicate = result else {
            Issue.record("Expected duplicate with Unicode")
            return
        }
    }
    
    @Test("Special characters don't affect matching")
    func specialCharactersDontAffectMatching() {
        // Arrange
        let existingItem = FoodItem(name: "Mom's Apple Pie", calories: 450)
        let existingItems = [existingItem]
        let sut = FoodDuplicateChecker()
        
        // Act
        let result = sut.checkForDuplicate(name: "mom's apple pie", in: existingItems)
        
        // Assert
        guard case .duplicate = result else {
            Issue.record("Expected duplicate with special characters")
            return
        }
    }
}

// MARK: - DuplicateCheckResult Tests

@Suite("DuplicateCheckResult Equatable Tests")
struct DuplicateCheckResultTests {
    
    @Test("Unique equals unique")
    func uniqueEqualsUnique() {
        let result1 = DuplicateCheckResult.unique
        let result2 = DuplicateCheckResult.unique
        
        #expect(result1 == result2)
    }
    
    @Test("Duplicate with same item equals")
    func duplicateWithSameItemEquals() {
        let item = FoodItem(name: "Apple", calories: 52)
        let result1 = DuplicateCheckResult.duplicate(existingItem: item)
        let result2 = DuplicateCheckResult.duplicate(existingItem: item)
        
        #expect(result1 == result2)
    }
    
    @Test("Unique not equals duplicate")
    func uniqueNotEqualsDuplicate() {
        let result1 = DuplicateCheckResult.unique
        let result2 = DuplicateCheckResult.duplicate(existingItem: FoodItem(name: "Apple", calories: 52))
        
        #expect(result1 != result2)
    }
}

