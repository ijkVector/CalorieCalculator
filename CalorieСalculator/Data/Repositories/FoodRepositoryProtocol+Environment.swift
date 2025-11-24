//
//  FoodRepositoryProtocol+Environment.swift
//  CalorieСalculator
//
//  Created by Иван Дроботов on 11/24/25.
//

import SwiftUI

// MARK: - Environment Key

private struct FoodRepositoryKey: @preconcurrency EnvironmentKey {
    @MainActor
    static let defaultValue: FoodRepositoryProtocol? = nil
}

// MARK: - EnvironmentValues Extension

extension EnvironmentValues {
    var foodRepository: FoodRepositoryProtocol? {
        get { self[FoodRepositoryKey.self] }
        set { self[FoodRepositoryKey.self] = newValue }
    }
}
