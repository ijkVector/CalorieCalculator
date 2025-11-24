//
//  Calorie_alculatorApp.swift
//  CalorieСalculator
//
//  Created by Иван Дроботов on 11/23/25.
//

import SwiftUI

@main
struct CalorieСalculatorApp: App {
    
    @State private var container = DIContainer()

    var body: some Scene {
        WindowGroup {
            CalorieСalculatorView()
        }
    }
}
