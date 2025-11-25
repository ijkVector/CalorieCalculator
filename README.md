# 🍎 Calorie Calculator

<p align="center">
  <img src="https://img.shields.io/badge/Platform-iOS%2018.0+-blue.svg" alt="Platform">
  <img src="https://img.shields.io/badge/Swift-6.0-orange.svg" alt="Swift">
  <img src="https://img.shields.io/badge/SwiftUI-5.0-green.svg" alt="SwiftUI">
  <img src="https://img.shields.io/badge/Architecture-Clean%20Architecture-red.svg" alt="Architecture">
  <img src="https://img.shields.io/badge/License-MIT-lightgrey.svg" alt="License">
</p>

Современное iOS приложение для отслеживания калорий с поддержкой установки дневных целей, редактирования записей и визуализации прогресса. Построено на SwiftUI с использованием Clean Architecture, SwiftData и современных практик разработки.

---

## ✨ Особенности

### 🎯 Основной функционал
- ✅ **Добавление приемов пищи** с названием и количеством калорий
- 📸 **Прикрепление фото** к каждому приему пищи
- ✏️ **Редактирование записей** по тапу или через swipe action
- 🗑️ **Удаление записей** с подтверждением
- 🎯 **Установка дневной цели** по калориям
- 📊 **Визуализация прогресса** с цветовой индикацией
- ⚠️ **Обнаружение дубликатов** с возможностью добавить или заменить
- 💾 **Автоматическое сохранение** всех данных

### 🎨 UX/UI
- 🌈 **Плавные анимации** для всех взаимодействий
- 🎬 **Spring animations** для прогресс-бара и счетчиков
- ✨ **Symbol effects** (iOS 17+) для иконок
- 📱 **Адаптивные sheets** с presentation detents
- 🎨 **Современный дизайн** с учетом Human Interface Guidelines
- ♿ **Accessibility** support

### 🏗️ Архитектура
- 🏛️ **Clean Architecture** (Presentation → Domain → Data)
- 🔒 **Actor isolation** для thread-safety
- 🧪 **100% testable** код с dependency injection
- 📦 **SwiftData** для персистентности
- 🎭 **MVVM** pattern в Presentation слое
- ⚡ **Async/await** для всех асинхронных операций

---

## 📱 Скриншоты

<table>
  <tr>
    <td><b>Главный экран</b><br/>Список приемов пищи с прогрессом</td>
    <td><b>Добавление еды</b><br/>С фото и валидацией</td>
    <td><b>Установка цели</b><br/>Дневной лимит калорий</td>
  </tr>
  <tr>
    <td><b>Редактирование</b><br/>Изменение существующих записей</td>
    <td><b>Empty State</b><br/>Приглашение добавить первую запись</td>
    <td><b>Прогресс</b><br/>Динамическая цветовая индикация</td>
  </tr>
</table>

---

## 🏛️ Архитектура

Проект построен по принципам **Clean Architecture** с четким разделением слоев:

```
┌─────────────────────────────────────────────┐
│         Presentation Layer                  │
│  ┌─────────────┐      ┌─────────────┐      │
│  │   Views     │ ───▶ │  ViewModels │      │
│  │  (SwiftUI)  │      │ (@Observable)│      │
│  └─────────────┘      └─────────────┘      │
└────────────────┬────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────┐
│           Domain Layer                      │
│  ┌─────────────┐      ┌─────────────┐      │
│  │   Models    │      │  Services   │      │
│  │  (Entities) │      │ (Use Cases) │      │
│  └─────────────┘      └─────────────┘      │
└────────────────┬────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────┐
│            Data Layer                       │
│  ┌─────────────┐      ┌─────────────┐      │
│  │Repositories │ ───▶ │   Stores    │      │
│  │  (actors)   │      │  (actors)   │      │
│  └─────────────┘      └─────────────┘      │
│         │                     │             │
│         ▼                     ▼             │
│    ┌──────────┐         ┌─────────┐        │
│    │   DTOs   │         │SwiftData│        │
│    └──────────┘         └─────────┘        │
└─────────────────────────────────────────────┘
```

### Слои приложения

#### 📱 Presentation Layer
**Расположение**: `CalorieСalculator/Presentation/`

- **Views**: SwiftUI компоненты (главный экран, компоненты)
- **ViewModels**: `@Observable` классы с бизнес-логикой UI
- **Ответственность**: Отображение данных, обработка взаимодействий

#### 🎯 Domain Layer
**Расположение**: `CalorieСalculator/Domain/`

- **Models**: Pure Swift модели (`FoodItem`, `CalorieGoal`)
- **Services**: 
  - `FoodInputValidator` - валидация ввода
  - `FoodDuplicateChecker` - проверка дубликатов
- **Ответственность**: Бизнес-логика, правила валидации

#### 💾 Data Layer
**Расположение**: `CalorieСalculator/Data/`

- **Repositories** (actors): 
  - `FoodRepository` - управление едой
  - `CalorieGoalRepository` - управление целями
- **Stores** (actors):
  - `FoodStore` - работа с SwiftData для еды
  - `CalorieGoalStore` - работа с SwiftData для целей
- **Models**: DTOs и Entities для SwiftData
- **Ответственность**: Персистентность данных, кэширование

---

## 🔧 Технологии

### Core Technologies
- **Swift 6.0** - Строгая типизация, structured concurrency
- **SwiftUI** - Декларативный UI фреймворк
- **SwiftData** - Persistence framework (преемник CoreData)
- **Swift Concurrency** - async/await, actors
- **Observation Framework** - Reactive state management

### Patterns & Practices
- **Clean Architecture** - Разделение слоев и зависимостей
- **MVVM** - Model-View-ViewModel для Presentation слоя
- **Dependency Injection** - DIContainer для управления зависимостями
- **Actor Isolation** - Thread-safety для data layer
- **Protocol-Oriented Programming** - Гибкость и тестируемость
- **Repository Pattern** - Абстракция источника данных

### Testing
- **Swift Testing** - Новый фреймворк тестирования (iOS 18+)
- **Mock Objects** - Изолированное тестирование компонентов
- **Unit Tests** - Покрытие бизнес-логики
- **UI Tests** - End-to-end тестирование

---

## 🚀 Установка

### Требования
- **Xcode**: 16.0 или новее
- **iOS**: 18.0 или новее
- **macOS**: Sonoma 14.0+ (для разработки)
- **Swift**: 6.0

### Шаги установки

1. **Клонируйте репозиторий**
```bash
git clone https://github.com/yourusername/CalorieCalculator.git
cd CalorieCalculator
```

2. **Откройте проект в Xcode**
```bash
open CalorieСalculator.xcodeproj
```

3. **Выберите симулятор или устройство**
- Target: iOS 18.0+
- Simulator: iPhone 15 или новее рекомендуется

4. **Соберите и запустите**
```bash
# Через Xcode
Cmd + R

# Или через терминал
xcodebuild -scheme CalorieСalculator -destination 'platform=iOS Simulator,name=iPhone 16' build
```

---

## 📖 Использование

### Добавление приема пищи

1. Введите название и калории в формате: `"Apple 52"`
2. (Опционально) Прикрепите фото через кнопку камеры
3. Нажмите "Add"

**Формат ввода:**
```
[Название] [Калории]
Примеры:
- "Apple 52"
- "Grilled Chicken 165"
- "Banana Smoothie 250"
```

**Правила валидации:**
- Название: 2-100 символов
- Калории: 1-10000 kcal
- Формат: название + пробел + число

### Установка цели

1. Нажмите кнопку "Goal" или "Set Goal" в toolbar
2. Введите дневную цель в калориях
3. Или выберите готовый вариант:
   - 1500 kcal (Low)
   - 2000 kcal (Moderate)
   - 2500 kcal (High)
   - 3000 kcal (Athletic)

### Редактирование записи

**Способ 1**: Tap на элементе списка
- Откроется sheet для редактирования

**Способ 2**: Swipe влево
- Появится синяя кнопка "Edit"

### Удаление записи

**Способ 1**: Swipe вправо
- Появится красная кнопка "Delete"

**Способ 2**: Swipe влево до конца списка
- Стандартное iOS delete action

---

## 🎨 Анимации

Приложение использует современные SwiftUI анимации для плавного UX:

### Типы анимаций

#### 🌊 Spring Animations
```swift
.animation(.spring(response: 0.6, dampingFraction: 0.8))
```
- **Где**: Progress bar, counters, buttons
- **Эффект**: Физически реалистичное движение

#### ✨ Transitions
```swift
.transition(.asymmetric(
    insertion: .move(edge: .leading).combined(with: .opacity),
    removal: .move(edge: .trailing).combined(with: .opacity)
))
```
- **Где**: List items, state changes
- **Эффект**: Плавные появление/исчезновение

#### 🔢 Numeric Text
```swift
.contentTransition(.numericText())
```
- **Где**: Calories counters, progress percentage
- **Эффект**: Плавное изменение чисел

#### 🎯 Symbol Effects
```swift
.symbolEffect(.bounce, value: isAnimating)
```
- **Где**: Icons, buttons
- **Эффект**: SF Symbols анимации

### Анимированные компоненты

| Компонент | Анимация | Длительность |
|-----------|----------|--------------|
| Food Item Row | Appearance, Scale, Fade | 0.5s |
| Progress Bar | Spring fill, Color transition | 0.6s |
| Total Calories | Numeric counter, Pulse | 0.4s |
| Empty State | Bounce, Fade-in | 0.8s |
| Sheets | System presentation | Default |
| Buttons | Scale, Color change | 0.2s |

---

## 🧪 Тестирование

### Структура тестов

```
CalorieСalculatorTests/
├── Mocks/
│   ├── MockFoodRepository.swift
│   ├── MockCalorieGoalRepository.swift
│   ├── MockFoodInputValidator.swift
│   ├── MockFoodDuplicateChecker.swift
│   └── FoodStoreMock.swift
├── CalorieCalculatorViewModelTests.swift  # 15 тестов
├── FoodInputValidatorTests.swift          # Валидация
├── FoodDuplicateCheckerTests.swift       # Дубликаты
├── FoodRepositoryTests.swift              # Repository layer
└── FoodStoreTests.swift                   # SwiftData layer
```

### Запуск тестов

**Через Xcode:**
```bash
Cmd + U
```

**Через терминал:**
```bash
# Все тесты
xcodebuild test -scheme CalorieСalculator -destination 'platform=iOS Simulator,name=iPhone 16'

# Только ViewModel тесты
xcodebuild test -scheme CalorieСalculator -only-testing:CalorieСalculatorTests/CalorieCalculatorViewModelTests
```

### Coverage

Основные компоненты с тестовым покрытием:

- ✅ **ViewModel**: 15 unit tests (100% критической логики)
- ✅ **Input Validator**: Полное покрытие всех правил
- ✅ **Duplicate Checker**: Все сценарии
- ✅ **Repository Layer**: CRUD операции
- ✅ **Store Layer**: SwiftData интеграция

---

## 📂 Структура проекта

```
CalorieСalculator/
│
├── App/
│   └── CalorieСalculatorApp.swift          # Entry point
│
├── Presentation/
│   ├── Views/
│   │   ├── CalorieСalculatorView.swift     # Main view
│   │   └── Components/
│   │       ├── FoodItemRow.swift           # List item
│   │       ├── GoalProgressSection.swift   # Progress bar
│   │       ├── TotalCaloriesSection.swift  # Total display
│   │       ├── EmptyStateView.swift        # Empty state
│   │       ├── FoodInputSection.swift      # Input form
│   │       ├── EditFoodItemSheet.swift     # Edit sheet
│   │       ├── GoalSettingView.swift       # Goal sheet
│   │       ├── SetGoalPromptSection.swift  # Goal prompt
│   │       └── QuickGoalButton.swift       # Quick goal
│   │
│   └── ViewModels/
│       └── CalorieСalculatorViewModel.swift # Main ViewModel
│
├── Domain/
│   ├── Models/
│   │   ├── FoodItem.swift                  # Food entity
│   │   ├── CalorieGoal.swift               # Goal entity
│   │   └── ValidatedFoodInput.swift        # Validated input
│   │
│   └── Services/
│       ├── FoodInputValidator/
│       │   ├── FoodInputValidating.swift   # Protocol
│       │   ├── FoodInputValidator.swift    # Implementation
│       │   ├── FoodInputValidationError.swift
│       │   └── ValidationRules.swift       # Rules
│       │
│       └── FoodDuplicateChecker/
│           ├── FoodDuplicateChecking.swift # Protocol
│           ├── FoodDuplicateChecker.swift  # Implementation
│           └── DuplicateCheckResult.swift  # Result enum
│
├── Data/
│   ├── Models/
│   │   ├── FoodItemDTO.swift              # Food DTO
│   │   ├── FoodItemEntity.swift           # SwiftData model
│   │   ├── CalorieGoalDTO.swift           # Goal DTO
│   │   └── CalorieGoalEntity.swift        # SwiftData model
│   │
│   ├── Repositories/
│   │   ├── FoodRepository.swift           # Food repo (actor)
│   │   ├── FoodRepositoryProtocol.swift
│   │   ├── FoodRepositoryError.swift
│   │   ├── CalorieGoalRepository.swift    # Goal repo (actor)
│   │   ├── CalorieGoalRepositoryProtocol.swift
│   │   └── CalorieGoalRepositoryError.swift
│   │
│   └── Stores/
│       ├── FoodStore.swift                # Food store (actor)
│       ├── FoodStoreProtocol.swift
│       ├── FoodStoreError.swift
│       ├── CalorieGoalStore.swift         # Goal store (actor)
│       ├── CalorieGoalStoreProtocol.swift
│       └── CalorieGoalStoreError.swift
│
├── DI/
│   └── DIContainer.swift                  # Dependency injection
│
└── Resources/
    └── Assets.xcassets/                   # Images, colors
```

---

## 🔐 Thread Safety

Проект использует современные Swift Concurrency механизмы для thread-safety:

### Actor Isolation

**Data Layer (все actors):**
```swift
actor FoodStore: FoodStoreProtocol { }
actor FoodRepository: FoodRepositoryProtocol { }
actor CalorieGoalStore: CalorieGoalStoreProtocol { }
actor CalorieGoalRepository: CalorieGoalRepositoryProtocol { }
```

**Преимущества:**
- ✅ Автоматическая изоляция данных
- ✅ Предотвращение race conditions
- ✅ IO операции на background thread
- ✅ UI остается отзывчивым

### Fresh Context Pattern

```swift
// Каждая операция получает свой контекст
private func makeContext() -> ModelContext {
    ModelContext(modelContainer)
}

func fetchItems() throws -> [FoodItemDTO] {
    let context = makeContext()  // Свежий контекст
    // ... операция
}
```

**Преимущества:**
- ✅ Нет shared mutable state
- ✅ Изоляция ошибок между операциями
- ✅ Предсказуемое поведение

---

## ⚡ Performance

### Оптимизации

1. **Lazy Loading**
   - Изображения загружаются по требованию
   - Список виртуализирован (SwiftUI List)

2. **Efficient Animations**
   - Spring damping для уменьшения колебаний
   - Conditional animations только для нужных изменений
   - Delayed animations для избежания одновременных эффектов

3. **SwiftData Optimizations**
   - Предикаты для фильтрации на уровне БД
   - Fetch только нужных полей
   - Batch операции где возможно

4. **Memory Management**
   - Value types (structs) для моделей
   - Actors для контроля над reference types
   - Автоматический ARC

---

## 🐛 Error Handling

### Graceful Error Handling

```swift
// Вместо fatalError - показ ошибки пользователю
do {
    let container = try DIContainer()
} catch {
    // Показываем InitializationErrorView
}
```

### Типизированные ошибки

```swift
enum FoodRepositoryError: Error {
    case cannotLoadFoods(reason: String)
    case cannotSaveFood(reason: String)
    case foodItemNotFound(UUID)
    case duplicateFoodEntry(UUID)
    case deviceStorageExhausted
    case invalidDate
}
```

### User-Facing Messages

```swift
extension FoodInputValidationError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .emptyInput:
            return "Please enter food name and calories"
        case .invalidFormat:
            return "Format: 'Food Name Calories' (e.g., 'Apple 52')"
        // ...
        }
    }
}
```

---

## 🔄 Data Flow

### Добавление еды (пример)

```
┌─────────────┐
│    User     │
│  Input Text │
└──────┬──────┘
       │
       ▼
┌─────────────────────┐
│      View           │
│  CalorieCalculator  │
│       View          │
└──────┬──────────────┘
       │ addFoodItem()
       ▼
┌─────────────────────┐
│    ViewModel        │
│  CalorieCalculator  │
│    ViewModel        │
└──────┬──────────────┘
       │ 1. validate()
       ▼
┌─────────────────────┐
│  InputValidator     │
│  (Domain Service)   │
└──────┬──────────────┘
       │ 2. checkDuplicate()
       ▼
┌─────────────────────┐
│ DuplicateChecker    │
│  (Domain Service)   │
└──────┬──────────────┘
       │ 3. createFood()
       ▼
┌─────────────────────┐
│  FoodRepository     │
│     (actor)         │
└──────┬──────────────┘
       │ 4. create()
       ▼
┌─────────────────────┐
│   FoodStore         │
│     (actor)         │
└──────┬──────────────┘
       │ 5. insert + save
       ▼
┌─────────────────────┐
│    SwiftData        │
│  (ModelContext)     │
└─────────────────────┘
```

---

## 📝 Code Style

### Naming Conventions
- **Types**: PascalCase (`FoodItem`, `CalorieGoal`)
- **Functions**: camelCase (`addFoodItem`, `fetchItems`)
- **Constants**: camelCase (`totalCalories`, `maxCalories`)
- **Private properties**: prefixed with `_` for stored, not for computed

### Organization
```swift
// MARK: - Properties
// MARK: - Initialization
// MARK: - Public Methods
// MARK: - Private Methods
// MARK: - Subviews (для Views)
```

### Protocols
```swift
// Naming: -Protocol suffix или -ing suffix
protocol FoodRepositoryProtocol { }
protocol FoodInputValidating { }
```