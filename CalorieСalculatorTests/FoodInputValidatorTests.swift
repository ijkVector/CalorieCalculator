//
//  FoodInputValidatorTests.swift
//  CalorieСalculatorTests
//
//  Created by Иван Дроботов on 11/24/25.
//

import Foundation
import Testing
@testable import CalorieСalculator

// MARK: - Test Suite

@Suite("FoodInputValidator Validation Tests")
struct FoodInputValidatorTests {
    
    let sut: FoodInputValidator
    
    init() {
        sut = FoodInputValidator()
    }
    
    // MARK: - Valid Input Tests
    
    @Test("Valid: Simple food name with calories")
    func validSimpleFoodWithCalories() throws {
        // Given
        let input = "Apple 52"
        
        // When
        let result = try sut.validate(input)
        
        // Then
        #expect(result.name == "Apple")
        #expect(result.calories == 52)
        #expect(result.originalInput == input)
    }
    
    @Test("Valid: Multi-word food name with calories")
    func validMultiWordFoodWithCalories() throws {
        // Given
        let input = "Grilled Chicken Breast 165"
        
        // When
        let result = try sut.validate(input)
        
        // Then
        #expect(result.name == "Grilled Chicken Breast")
        #expect(result.calories == 165)
    }
    
    @Test("Valid: Food with multiple spaces")
    func validFoodWithMultipleSpaces() throws {
        // Given
        let input = "Fresh Green Salad Bowl 120"
        
        // When
        let result = try sut.validate(input)
        
        // Then
        #expect(result.name == "Fresh Green Salad Bowl")
        #expect(result.calories == 120)
    }
    
    @Test("Valid: Leading/trailing whitespace trimmed")
    func validInputWithWhitespace() throws {
        // Given
        let input = "  Banana 89  "
        
        // When
        let result = try sut.validate(input)
        
        // Then
        #expect(result.name == "Banana")
        #expect(result.calories == 89)
    }
    
    @Test("Valid: Large calorie value")
    func validLargeCalories() throws {
        // Given
        let input = "Large Pizza 2400"
        
        // When
        let result = try sut.validate(input)
        
        // Then
        #expect(result.name == "Large Pizza")
        #expect(result.calories == 2400)
    }
    
    @Test("Valid: Single calorie")
    func validSingleCalorie() throws {
        // Given
        let input = "Lettuce 1"
        
        // When
        let result = try sut.validate(input)
        
        // Then
        #expect(result.name == "Lettuce")
        #expect(result.calories == 1)
    }
    
    @Test("Valid: Maximum allowed calories")
    func validMaximumCalories() throws {
        // Given
        let input = "Feast 10000"
        
        // When
        let result = try sut.validate(input)
        
        // Then
        #expect(result.name == "Feast")
        #expect(result.calories == 10000)
    }
    
    // MARK: - Invalid Input Tests - Empty & Format
    
    @Test("Invalid: Empty string")
    func invalidEmptyString() throws {
        // Given
        let input = ""
        
        // When/Then
        #expect(throws: FoodInputValidationError.emptyInput) {
            try sut.validate(input)
        }
    }
    
    @Test("Invalid: Only whitespace")
    func invalidOnlyWhitespace() throws {
        // Given
        let input = "   "
        
        // When/Then
        #expect(throws: FoodInputValidationError.emptyInput) {
            try sut.validate(input)
        }
    }
    
    @Test("Invalid: Only food name without calories")
    func invalidOnlyFoodName() throws {
        // Given
        let input = "Apple"
        
        // When/Then
        #expect(throws: FoodInputValidationError.invalidFormat) {
            try sut.validate(input)
        }
    }
    
    @Test("Invalid: Only calories without food name")
    func invalidOnlyCalories() throws {
        // Given
        let input = "52"
        
        // When/Then
        #expect(throws: FoodInputValidationError.invalidFormat) {
            try sut.validate(input)
        }
    }
    
    // MARK: - Invalid Input Tests - Calories
    
    @Test("Invalid: Non-numeric calories")
    func invalidNonNumericCalories() throws {
        // Given
        let input = "Apple abc"
        
        // When/Then
        #expect(throws: FoodInputValidationError.caloriesNotNumeric) {
            try sut.validate(input)
        }
    }
    
    @Test("Invalid: Negative calories")
    func invalidNegativeCalories() throws {
        // Given
        let input = "Apple -52"
        
        // When/Then
        #expect(throws: FoodInputValidationError.caloriesOutOfRange(value: -52)) {
            try sut.validate(input)
        }
    }
    
    @Test("Invalid: Zero calories")
    func invalidZeroCalories() throws {
        // Given
        let input = "Water 0"
        
        // When/Then
        #expect(throws: FoodInputValidationError.caloriesOutOfRange(value: 0)) {
            try sut.validate(input)
        }
    }
    
    @Test("Invalid: Calories exceeding maximum")
    func invalidExcessiveCalories() throws {
        // Given
        let input = "Mega Feast 10001"
        
        // When/Then
        #expect(throws: FoodInputValidationError.caloriesOutOfRange(value: 10001)) {
            try sut.validate(input)
        }
    }
    
    @Test("Invalid: Decimal calories")
    func invalidDecimalCalories() throws {
        // Given
        let input = "Apple 52.5"
        
        // When/Then
        #expect(throws: FoodInputValidationError.caloriesNotNumeric) {
            try sut.validate(input)
        }
    }
    
    // MARK: - Edge Cases - Multiple Numbers
    
    @Test("Edge: Two numbers in name")
    func twoNumbersInName() throws {
        // Given
        let input = "12 52"
        
        // When
        let result = try sut.validate(input)
        
        // Then
        #expect(result.name == "12")
        #expect(result.calories == 52)
    }
    
    @Test("Edge: Multiple numbers in input")
    func invalidMultipleNumbers() throws {
        // Given
        let input = "2 Apples 104"
        
        // When
        let result = try sut.validate(input)
        
        // Then
        // Should be valid - "2 Apples" is the name, 104 is calories
        #expect(result.name == "2 Apples")
        #expect(result.calories == 104)
    }
    
    @Test("Edge: Multiple trailing numbers")
    func multipleTrailingNumbers() throws {
        // Given
        let input = "Apple 52 100"
        
        // When
        let result = try sut.validate(input)
        
        // Then
        // Берёт последнее число как калории
        #expect(result.name == "Apple 52")
        #expect(result.calories == 100)
    }
    
    // MARK: - Edge Cases - Name Length
    
    @Test("Edge: Name too short")
    func nameTooShort() throws {
        // Given
        let input = " 100"  // Только пробел + калории
        
        // When/Then
        // После фильтрации пробелов остается только "100" - один компонент
        #expect(throws: FoodInputValidationError.invalidFormat) {
            try sut.validate(input)
        }
    }
    
    @Test("Edge: Name too long")
    func nameTooLong() throws {
        // Given
        let longName = String(repeating: "A", count: 101)
        let input = "\(longName) 100"
        
        // When/Then
        #expect(throws: FoodInputValidationError.nameTooLong) {
            try sut.validate(input)
        }
    }
    
    @Test("Edge: Name at maximum length")
    func nameAtMaximumLength() throws {
        // Given
        let maxName = String(repeating: "A", count: 100)
        let input = "\(maxName) 100"
        
        // When
        let result = try sut.validate(input)
        
        // Then
        #expect(result.name == maxName)
        #expect(result.calories == 100)
    }
    
    // MARK: - Edge Cases - Calorie Boundaries
    
    @Test("Edge: Calories at minimum boundary")
    func caloriesAtMinimum() throws {
        // Given
        let input = "Apple 1"
        
        // When
        let result = try sut.validate(input)
        
        // Then
        #expect(result.calories == 1)
    }
    
    @Test("Edge: Calories below minimum")
    func caloriesBelowMinimum() throws {
        // Given
        let input = "Apple 0"
        
        // When/Then
        #expect(throws: FoodInputValidationError.caloriesOutOfRange(value: 0)) {
            try sut.validate(input)
        }
    }
    
    @Test("Edge: Calories at maximum boundary")
    func caloriesAtMaximum() throws {
        // Given
        let input = "Apple 10000"
        
        // When
        let result = try sut.validate(input)
        
        // Then
        #expect(result.calories == 10_000)
    }
    
    @Test("Edge: Calories above maximum")
    func caloriesAboveMaximum() throws {
        // Given
        let input = "Apple 10001"
        
        // When/Then
        #expect(throws: FoodInputValidationError.caloriesOutOfRange(value: 10_001)) {
            try sut.validate(input)
        }
    }
    
    // MARK: - Edge Cases - Whitespace Handling
    
    @Test("Edge: Tab characters")
    func edgeCaseTabCharacters() throws {
        // Given
        let input = "Apple\t52"  // Символ таба
        
        // When
        let result = try sut.validate(input)
        
        // Then
        // Таб рассматривается как разделитель пробела
        #expect(result.name == "Apple")
        #expect(result.calories == 52)
    }
    
    @Test("Edge: Newline characters")
    func edgeCaseNewlineCharacters() throws {
        // Given
        let input = "Apple\n52"
        
        // When
        let result = try sut.validate(input)
        
        // Then
        // Newline рассматривается как разделитель
        #expect(result.name == "Apple")
        #expect(result.calories == 52)
    }
    
    @Test("Edge: Mixed whitespace normalization")
    func mixedWhitespaceNormalization() throws {
        // Given
        let input = "Green  \t  Apple\n\n52"  // Множественные пробелы, табы, новые строки
        
        // When
        let result = try sut.validate(input)
        
        // Then
        #expect(result.name == "Green Apple")  // Нормализовано в одинарные пробелы
        #expect(result.calories == 52)
    }
    
    @Test("Edge: Original input preserved")
    func originalInputPreserved() throws {
        // Given
        let input = "  Apple   52  "  // С дополнительными пробелами
        
        // When
        let result = try sut.validate(input)
        
        // Then
        #expect(result.originalInput == input)  // Ровно как введено
        #expect(result.name == "Apple")  // Но название очищено
    }
    
    // MARK: - Edge Cases - Special Characters
    
    @Test("Edge: Very long food name")
    func edgeCaseVeryLongFoodName() throws {
        // Given
        let input = "Super Delicious Homemade Organic Fresh Grilled Chicken Caesar Salad With Extra Cheese 350"
        
        // When
        let result = try sut.validate(input)
        
        // Then
        #expect(result.name == "Super Delicious Homemade Organic Fresh Grilled Chicken Caesar Salad With Extra Cheese")
        #expect(result.calories == 350)
    }
    
    @Test("Edge: Special characters in name")
    func edgeCaseSpecialCharactersInName() throws {
        // Given
        let input = "Mom's Apple Pie 450"
        
        // When
        let result = try sut.validate(input)
        
        // Then
        #expect(result.name == "Mom's Apple Pie")
        #expect(result.calories == 450)
    }
    
    @Test("Edge: Unicode characters in name")
    func edgeCaseUnicodeCharacters() throws {
        // Given
        let input = "Суши Ролл 280"
        
        // When
        let result = try sut.validate(input)
        
        // Then
        #expect(result.name == "Суши Ролл")
        #expect(result.calories == 280)
    }
    
    @Test("Edge: Emoji in name")
    func edgeCaseEmojiInName() throws {
        // Given
        let input = "🍎 Apple 52"
        
        // When
        let result = try sut.validate(input)
        
        // Then
        #expect(result.name == "🍎 Apple")
        #expect(result.calories == 52)
    }
}

// MARK: - ValidatedFoodInput Tests

@Suite("ValidatedFoodInput Model Tests")
struct ValidatedFoodInputTests {
    
    @Test("Model: Trims whitespace from name")
    func modelTrimsWhitespace() {
        // Given & When
        let result = ValidatedFoodInput(
            name: "  Apple  ",
            calories: 52,
            originalInput: "  Apple  52"
        )
        
        // Then
        #expect(result.name == "Apple")
    }
    
    @Test("Model: Preserves original input exactly")
    func modelPreservesOriginalInput() {
        // Given & When
        let input = "  Apple   52  "
        let result = ValidatedFoodInput(
            name: "Apple",
            calories: 52,
            originalInput: input
        )
        
        // Then
        #expect(result.originalInput == input)
    }
    
    @Test("Model: Equatable works correctly")
    func modelEquatableWorks() {
        // Given
        let result1 = ValidatedFoodInput(name: "Apple", calories: 52, originalInput: "Apple 52")
        let result2 = ValidatedFoodInput(name: "Apple", calories: 52, originalInput: "Apple 52")
        let result3 = ValidatedFoodInput(name: "Banana", calories: 89, originalInput: "Banana 89")
        
        // Then
        #expect(result1 == result2)
        #expect(result1 != result3)
    }
}

// MARK: - ValidationRules Tests

@Suite("ValidationRules Tests")
struct ValidationRulesTests {
    
    @Test("CalorieValidationRules: Valid range")
    func calorieRulesValidRange() {
        #expect(CalorieValidationRules.isValid(1))
        #expect(CalorieValidationRules.isValid(100))
        #expect(CalorieValidationRules.isValid(5000))
        #expect(CalorieValidationRules.isValid(10000))
    }
    
    @Test("CalorieValidationRules: Invalid range")
    func calorieRulesInvalidRange() {
        #expect(!CalorieValidationRules.isValid(0))
        #expect(!CalorieValidationRules.isValid(-1))
        #expect(!CalorieValidationRules.isValid(10001))
        #expect(!CalorieValidationRules.isValid(100000))
    }
    
    @Test("NameValidationRules: Valid length")
    func nameRulesValidLength() {
        #expect(NameValidationRules.isValid("A"))
        #expect(NameValidationRules.isValid("Apple"))
        #expect(NameValidationRules.isValid(String(repeating: "A", count: 50)))
        #expect(NameValidationRules.isValid(String(repeating: "A", count: 100)))
    }
    
    @Test("NameValidationRules: Invalid length")
    func nameRulesInvalidLength() {
        #expect(!NameValidationRules.isValid(""))
        #expect(!NameValidationRules.isValid(String(repeating: "A", count: 101)))
        #expect(!NameValidationRules.isValid(String(repeating: "A", count: 200)))
    }
}
