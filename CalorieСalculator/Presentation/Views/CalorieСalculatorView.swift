//
//  ContentView.swift
//  CalorieСalculator
//
//  Created by Иван Дроботов on 11/23/25.
//

import SwiftUI

struct CalorieСalculatorView: View {
    
    @State var viewModel: CalorieСalculatorViewModel
    
    @State private var inputText: String = ""
    @State private var showDeleteAlert: Bool = false
    @State private var itemToDelete: FoodItem?
    
    init(viewModel: CalorieСalculatorViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Input Section
                inputSection
                
                // Goal Section
                if viewModel.hasGoal {
                    goalProgressSection
                } else {
                    setGoalPromptSection
                }
                
                // List Section
                if viewModel.isLoading {
                    Spacer()
                    ProgressView("Loading...")
                    Spacer()
                } else if viewModel.isEmpty {
                    emptyStateView
                } else {
                    foodListSection
                }
                
                // Total Calories Section
                totalCaloriesSection
            }
            .navigationTitle("Calorie Calculator")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { viewModel.showGoalSheet = true }) {
                        HStack(spacing: 4) {
                            Image(systemName: "target")
                            Text(viewModel.hasGoal ? "Goal" : "Set Goal")
                                .font(.subheadline.weight(.medium))
                        }
                        .foregroundStyle(viewModel.hasGoal ? .blue : .blue)
                    }
                }
            }
            .sheet(isPresented: $viewModel.showGoalSheet) {
                GoalSettingView(viewModel: viewModel)
            }
            .task {
                await viewModel.loadFoodItems()
            }
            .alert("Error", isPresented: $viewModel.showErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
            .alert("Delete Item", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    if let item = itemToDelete {
                        Task {
                            await viewModel.deleteFoodItem(by: item.id)
                        }
                    }
                }
            } message: {
                Text("Are you sure you want to delete this item?")
            }
            .alert(
                viewModel.duplicateAlertTitle,
                isPresented: $viewModel.showDuplicateAlert
            ) {
                Button("Cancel", role: .cancel) {
                    // Очистка состояния
                    viewModel.duplicateItem = nil
                }
                
                Button("Add Anyway") {
                    Task {
                        await viewModel.addDuplicateAnyway()
                    }
                }
                
                Button("Replace", role: .destructive) {
                    Task {
                        await viewModel.replaceWithNew()
                    }
                }
            } message: {
                Text(viewModel.duplicateAlertMessage)
            }
        }
    }
    
    // MARK: - Input Section
    
    private var inputSection: some View {
        HStack(spacing: 12) {
            TextField("Enter food (e.g., Apple 52)", text: $inputText)
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()
            
            Button(action: addFoodItem) {
                Text("Add")
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(inputText.isEmpty ? Color.gray : Color.blue)
                    .cornerRadius(8)
            }
            .disabled(inputText.isEmpty)
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    // MARK: - Food List Section
    
    private var foodListSection: some View {
        List {
            ForEach(viewModel.items) { item in
                FoodItemRow(item: item)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            itemToDelete = item
                            showDeleteAlert = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        }
        .listStyle(.plain)
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "fork.knife.circle")
                .font(.system(size: 60))
                .foregroundStyle(.gray)
            Text("No meals added yet")
                .font(.title3)
                .foregroundStyle(.secondary)
            Text("Add your first meal above")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
            Spacer()
        }
    }
    
    // MARK: - Set Goal Prompt Section
    
    private var setGoalPromptSection: some View {
        Button(action: {
            viewModel.showGoalSheet = true
        }) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.15))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "target")
                        .font(.system(size: 24))
                        .foregroundStyle(.blue)
                }
                
                // Text content
                VStack(alignment: .leading, spacing: 4) {
                    Text("Set Your Daily Goal")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    Text("Track your progress with a calorie target")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Arrow
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue.opacity(0.2), lineWidth: 1)
            )
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Goal Progress Section
    
    private var goalProgressSection: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Daily Goal")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    if let goal = viewModel.calorieGoal {
                        Text("\(goal.dailyCalorieTarget) kcal")
                            .font(.headline)
                            .foregroundStyle(.primary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Remaining")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text("\(viewModel.remainingCalories) kcal")
                        .font(.headline)
                        .foregroundStyle(viewModel.isGoalExceeded ? .red : .green)
                }
            }
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 20)
                    
                    // Progress
                    RoundedRectangle(cornerRadius: 8)
                        .fill(progressBarColor)
                        .frame(
                            width: geometry.size.width * viewModel.goalProgress,
                            height: 20
                        )
                        .animation(.easeInOut(duration: 0.3), value: viewModel.goalProgress)
                    
                    // Percentage text
                    Text("\(Int(viewModel.goalProgress * 100))%")
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 20)
        }
        .padding()
        .background(Color(.systemBackground))
        .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
    }
    
    private var progressBarColor: Color {
        let progress = viewModel.goalProgress
        
        if progress < 0.5 {
            return .green
        } else if progress < 0.8 {
            return .yellow
        } else if progress <= 1.0 {
            return .orange
        } else {
            return .red
        }
    }
    
    // MARK: - Total Calories Section
    
    private var totalCaloriesSection: some View {
        VStack(spacing: 8) {
            Divider()
            
            HStack {
                Text("Total Calories")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Text("\(viewModel.totalCalories)")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                
                Text("kcal")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 8)
            }
            .padding()
        }
        .background(Color(.secondarySystemBackground))
    }
    
    // MARK: - Actions
    
    private func addFoodItem() {
        Task {
            await viewModel.addFoodItem(input: inputText)
            inputText = ""
        }
    }
}

// MARK: - Food Item Row

struct FoodItemRow: View {
    let item: FoodItem
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            if let imageData = item.imageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 50, height: 50)
                    .overlay {
                        Image(systemName: "fork.knife")
                            .foregroundStyle(.gray)
                    }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                
                Text(item.timestamp, style: .time)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text("\(item.calories)")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.blue)
            
            Text("kcal")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Goal Setting View

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
                
                if viewModel.hasGoal {
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
                
                // Quick suggestions
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
    
    private func saveGoal() {
        guard let target = Int(goalText), target > 0 else { return }
        
        Task {
            await viewModel.setCalorieGoal(dailyTarget: target)
            dismiss()
        }
    }
}

// MARK: - Quick Goal Button

struct QuickGoalButton: View {
    let value: Int
    @Binding var goalText: String
    
    var body: some View {
        Button(action: {
            goalText = "\(value)"
        }) {
            Text("\(value)")
                .font(.subheadline.bold())
                .foregroundStyle(.blue)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}
