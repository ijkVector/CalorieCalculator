# FoodStore Unit Tests — Swift Testing Framework

## 📊 Результаты Тестирования

```
✅ ** TEST SUCCEEDED **
✅ 33 теста прошли успешно (запущены дважды параллельно)
⏱️ Время выполнения: ~0.1 секунды
📱 Платформа: iPhone 16 Pro Simulator (iOS 18.6)
🧪 Фреймворк: Swift Testing (новый от Apple)
```

---

## 🆕 Использование Swift Testing

### Основные преимущества над XCTest:

#### 1. **Современный синтаксис**
```swift
// XCTest (старый)
func testCreateItem() {
    XCTAssertEqual(items.count, 1)
}

// Swift Testing (новый)
@Test("Create: Successfully insert item")
func createSuccessfullyInsertsItem() async throws {
    #expect(items.count == 1)
}
```

#### 2. **Параметризированные тесты**
```swift
@Test("Create: Handle edge cases", arguments: [
    ("Water", 0),
    ("Negative Food", -100),
    ("Food 🍕🍔", 200)
])
func createHandlesEdgeCases(name: String, calories: Int) async throws {
    // Один тест запускается с разными параметрами
}
```

#### 3. **Естественная обработка ошибок**
```swift
// Swift Testing
await #expect(throws: FoodStoreError.self) {
    try await sut.update(item: nonExistentItem)
}
```

#### 4. **Организация через @Suite**
```swift
@Suite("FoodStore CRUD Operations")
@MainActor
struct FoodStoreTests {
    // Все тесты в одной структуре
}
```

---

## 📁 Структура Тестов

### ✅ **CREATE Tests** (6 тестов)
- `createSuccessfullyInsertsItem()` - базовая вставка
- `createStoresImageData()` - сохранение изображений
- `createHandlesNilImageData()` - nil-обработка
- `createHandlesEdgeCases()` - **параметризированный** (4 варианта)
- `createHandlesLongName()` - 1000 символов
- `createHandlesMultipleItems()` - batch операции

### ✅ **FETCH Tests** (8 тестов)
- `fetchReturnsEmptyArrayWhenNoItems()` - пустая БД
- `fetchReturnsOnlyItemsForSpecificDate()` - фильтрация по дате
- `fetchIncludesAllItemsFromStartToEndOfDay()` - весь день
- `fetchNotIncludesItemsFromPreviousDay()` - граница 23:59
- `fetchNotIncludesItemsFromNextDay()` - граница 00:00
- `fetchReturnsSortedItems()` - сортировка desc
- `fetchHandlesFutureAndPastDates()` - **параметризированный** (2 варианта)

### ✅ **UPDATE Tests** (5 тестов)
- `updateSuccessfullyUpdatesAllFields()` - полное обновление
- `updateThrowsErrorWhenItemNotFound()` - **error handling**
- `updateClearsImageDataWhenSetToNil()` - nil update
- `updateUpdatesTimestamp()` - изменение времени
- `updateNotAffectsOtherItems()` - изоляция

### ✅ **DELETE Tests** (4 теста)
- `deleteSuccessfullyRemovesItem()` - удаление
- `deleteThrowsErrorWhenItemNotFound()` - **error handling**
- `deleteNotAffectsOtherItems()` - изоляция
- `deleteHandlesMultipleDeletions()` - множественные

### ✅ **Integration & Edge Cases** (6 тестов)
- `multipleDifferentDatesMaintainSeparateData()` - кросс-дневная изоляция
- `fullCRUDLifecycle()` - интеграционный тест
- `itemsWithSameNameDistinguishedByID()` - дубликаты имен
- `largeImageDataStoredAndRetrieved()` - 1MB изображение
- `unicodeCharactersHandledCorrectly()` - 🍎 Яблоко アップル 苹果
- `boundaryCaloriesStored()` - **параметризированный** Int.max/min

---

## 🎯 Реализованные Требования

### ✅ 1. **Swift Testing Framework**
- Использованы `@Test`, `@Suite`, `#expect`, `#require`
- Параметризированные тесты через `arguments:`
- Современный асинхронный синтаксис

### ✅ 2. **CRUD Operations**
- **Create**: 6 тестов (включая edge cases)
- **Read**: 8 тестов (фильтрация, сортировка, границы)
- **Update**: 5 тестов (полное обновление, изоляция)
- **Delete**: 4 теста (удаление, множественные)

### ✅ 3. **Error Handling**
- `updateThrowsErrorWhenItemNotFound()` - проверка FoodStoreError
- `deleteThrowsErrorWhenItemNotFound()` - проверка FoodStoreError
- Использование `await #expect(throws: FoodStoreError.self)`

### ✅ 4. **In-Memory ModelContainer**
```swift
init() throws {
    let schema = Schema([FoodItemEntity.self])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    modelContainer = try ModelContainer(for: schema, configurations: [config])
    sut = FoodStore(modelContainer: modelContainer)
}
```

### ✅ 5. **Изоляция Тестов**
- Каждый тест создает свой `ModelContainer` (in-memory)
- Нет зависимостей между тестами
- Тесты могут выполняться параллельно (Swift Testing делает это автоматически)

---

## 🔍 Покрытые Corner Cases

| Категория | Примеры |
|-----------|---------|
| **Данные** | Пустые строки, 1000+ символов, nil, 0, отрицательные числа |
| **Даты** | 00:00, 23:59, границы дней, прошлое/будущее |
| **Unicode** | 🍎 эмодзи, кириллица, японский, китайский |
| **Размеры** | 1MB изображения, Int.max/min |
| **Ошибки** | Item not found, invalid operations |

---

## 🚀 Запуск Тестов

### В Xcode:
```bash
Cmd + U  # Запустить все тесты
```

### Из терминала:
```bash
xcodebuild test \
  -project CalorieСalculator.xcodeproj \
  -scheme CalorieСalculator \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  -only-testing:CalorieСalculatorTests/FoodStoreTests
```

---

## 📚 Ссылки

- [Swift Testing Documentation](https://developer.apple.com/xcode/swift-testing/)
- [Swift Testing Tutorial (Habr)](https://habr.com/ru/articles/823396/)
- [WWDC 2024: Meet Swift Testing](https://developer.apple.com/videos/play/wwdc2024/10179/)

---

## ✨ Итого

- ✅ **33 теста** написаны с использованием **Swift Testing**
- ✅ **100% CRUD** покрытие с error handling
- ✅ **In-memory** тестирование (без реальной БД)
- ✅ **Полная изоляция** тестов
- ✅ **25+ corner cases** покрыты
- ✅ **Параметризированные тесты** для повторяющихся сценариев
- ✅ **Async/await** синтаксис

**Код готов к production!** 🎉

