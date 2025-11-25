//
//  GoalSettingView.swift
//  CalorieСalculator
//
//  Created by Иван Дроботов on 11/24/25.
//

import SwiftUI

struct GoalSettingView: View {
    @State var viewModel: CalorieСalculatorViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var goalText: String = ""
    @State private var showDeleteConfirmation: Bool = false
    
    init(viewModel: CalorieСalculatorViewModel) {
        self.viewModel = viewModel
        if let goal = viewModel.calorieGoal {
            _goalText = State(initialValue: "\(goal.dailyCalorieTarget)")
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                goalInputSection
                
                if viewModel.hasGoal {
                    deleteGoalSection
                }
                
                quickSuggestionsSection
            }
            .navigationTitle(viewModel.hasGoal ? "Edit Goal" : "Set Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveGoal()
                    }
                    .disabled(goalText.isEmpty || Int(goalText) == nil)
                }
            }
            .alert("Remove Goal", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Remove", role: .destructive) {
                    Task {
                        await viewModel.deleteGoal()
                        dismiss()
                    }
                }
            } message: {
                Text("Are you sure you want to remove your daily calorie goal?")
            }
        }
    }
    
    // MARK: - Sections
    
    private var goalInputSection: some View {
        Section {
            HStack {
                Text("Daily Goal")
                    .font(.headline)
                
                Spacer()
                
                TextField("2000", text: $goalText)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .font(.title2.bold())
                
                Text("kcal")
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text("Set Your Daily Calorie Goal")
        } footer: {
            Text("Enter your target calories for the day. The progress bar will update as you add meals.")
        }
    }
    
    private var deleteGoalSection: some View {
        Section {
            Button(role: .destructive) {
                showDeleteConfirmation = true
            } label: {
                HStack {
                    Spacer()
                    Text("Remove Goal")
                    Spacer()
                }
            }
        }
    }
    
    private var quickSuggestionsSection: some View {
        Section {
            VStack(spacing: 12) {
                Text("Quick Suggestions")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 8) {
                    QuickGoalButton(value: 1500, goalText: $goalText)
                    QuickGoalButton(value: 2000, goalText: $goalText)
                    QuickGoalButton(value: 2500, goalText: $goalText)
                    QuickGoalButton(value: 3000, goalText: $goalText)
                    QuickGoalButton(value: 3500, goalText: $goalText)
                    QuickGoalButton(value: 4000, goalText: $goalText)
                }
            }
            .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
        }
    }
    
    // MARK: - Actions
    
    private func saveGoal() {
        guard let target = Int(goalText), target > 0 else { return }
        
        Task {
            await viewModel.setCalorieGoal(dailyTarget: target)
            dismiss()
        }
    }
}

