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
        let parsed = parseInput(inputText)
        
        guard let name = parsed.name, let calories = parsed.calories else {
            return
        }
        
        Task {
            await viewModel.addFoodItem(name: name, calories: calories)
            inputText = ""
        }
    }
    
    private func parseInput(_ input: String) -> (name: String?, calories: Int?) {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        let components = trimmed.split(separator: " ")
        
        guard components.count >= 2 else {
            return (nil, nil)
        }
        
        // Last component should be calories
        if let calories = Int(components.last!) {
            let name = components.dropLast().joined(separator: " ")
            return (name, calories)
        }
        
        return (nil, nil)
    }
}

// MARK: - Food Item Row

struct FoodItemRow: View {
    let item: FoodItem
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // Image placeholder or actual image
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
