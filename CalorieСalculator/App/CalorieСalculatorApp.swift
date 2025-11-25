//
//  Calorie_alculatorApp.swift
//  CalorieСalculator
//
//  Created by Иван Дроботов on 11/23/25.
//

import SwiftUI

struct InitializationErrorView: View {
    let error: Error
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.red)
            
            Text("Failed to Start App")
                .font(.title)
                .fontWeight(.bold)
            
            Text(error.localizedDescription)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .foregroundColor(.secondary)
            
            Button("Restart App") {
                // In a real app, you could try to reinitialize or show recovery instructions
                fatalError("User requested restart")
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

@main
struct CalorieСalculatorApp: App {
    @State private var container: DIContainer?
    @State private var initError: Error?
    
    init() {
        do {
            let newContainer = try DIContainer()
            _container = State(initialValue: newContainer)
        } catch {
            _initError = State(initialValue: error)
        }
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if let container {
                    // Successful initialization
                    CalorieСalculatorView(
                        viewModel: container.makeCalorieViewModel()
                    )
                } else if let error = initError {
                    // Show error to user
                    InitializationErrorView(error: error)
                } else {
                    // Loading state (theoretically should not happen)
                    ProgressView("Loading...")
                }
            }
        }
    }
}
