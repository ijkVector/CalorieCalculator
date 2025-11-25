//
//  ContentView.swift
//  CalorieСalculator
//
//  Created by Иван Дроботов on 11/23/25.
//

import SwiftUI
import PhotosUI

struct CalorieСalculatorView: View {
    
    @State var viewModel: CalorieСalculatorViewModel
    
    @State private var inputText: String = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var showDeleteAlert: Bool = false
    @State private var itemToDelete: FoodItem?
    @State private var itemToEdit: FoodItem?
    
    // Animation namespace for matched geometry
    @Namespace private var animation
    
    init(viewModel: CalorieСalculatorViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Input Section
                FoodInputSection(
                    inputText: $inputText,
                    selectedPhoto: $selectedPhoto,
                    selectedImageData: $selectedImageData,
                    onAdd: addFoodItem
                )
                
                // Goal Section with transition
                if viewModel.hasGoal, let goal = viewModel.calorieGoal {
                    GoalProgressSection(
                        goal: goal,
                        totalCalories: viewModel.totalCalories,
                        remainingCalories: viewModel.remainingCalories,
                        goalProgress: viewModel.goalProgress,
                        isGoalExceeded: viewModel.isGoalExceeded
                    )
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.8).combined(with: .opacity),
                        removal: .scale(scale: 0.8).combined(with: .opacity)
                    ))
                    .id("goalProgress")
                } else {
                    SetGoalPromptSection {
                        viewModel.showGoalSheet = true
                    }
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.8).combined(with: .opacity),
                        removal: .scale(scale: 0.8).combined(with: .opacity)
                    ))
                    .id("goalPrompt")
                }
                
                // List Section with smooth transitions
                if viewModel.isLoading {
                    Spacer()
                    ProgressView("Loading...")
                        .scaleEffect(1.2)
                        .transition(.scale.combined(with: .opacity))
                    Spacer()
                } else if viewModel.isEmpty {
                    EmptyStateView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity),
                            removal: .scale.combined(with: .opacity)
                        ))
                } else {
                    foodListSection
                        .transition(.opacity)
                }
                
                // Total Calories Section
                TotalCaloriesSection(totalCalories: viewModel.totalCalories)
            }
            .navigationTitle("Calorie Calculator")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { 
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.showGoalSheet = true
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "target")
                                .symbolEffect(.bounce, value: viewModel.showGoalSheet)
                            Text(viewModel.hasGoal ? "Goal" : "Set Goal")
                                .font(.subheadline.weight(.medium))
                        }
                        .foregroundStyle(viewModel.hasGoal ? .blue : .blue)
                    }
                }
            }
            .animation(.easeInOut(duration: 0.3), value: viewModel.hasGoal)
            .animation(.easeInOut(duration: 0.3), value: viewModel.isLoading)
            .animation(.easeInOut(duration: 0.3), value: viewModel.isEmpty)
            .sheet(isPresented: $viewModel.showGoalSheet) {
                GoalSettingView(viewModel: viewModel)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(item: $itemToEdit) { item in
                EditFoodItemSheet(item: item) { editedText, imageData in
                    Task {
                        await handleEditSave(for: item, editedText: editedText, imageData: imageData)
                    }
                }
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
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
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            itemToEdit = item
                        }
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            withAnimation(.easeOut(duration: 0.3)) {
                                itemToDelete = item
                                showDeleteAlert = true
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: false) {
                        Button {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                itemToEdit = item
                            }
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        .tint(.blue)
                    }
                    .transition(.asymmetric(
                        insertion: .move(edge: .leading).combined(with: .opacity),
                        removal: .move(edge: .trailing).combined(with: .opacity)
                    ))
            }
            .onDelete { indexSet in
                withAnimation(.easeOut(duration: 0.3)) {
                    for index in indexSet {
                        itemToDelete = viewModel.items[index]
                        showDeleteAlert = true
                    }
                }
            }
        }
        .listStyle(.plain)
        .animation(.easeInOut(duration: 0.3), value: viewModel.items.count)
    }
    
    // MARK: - Actions
    
    private func addFoodItem() {
        withAnimation(.easeInOut(duration: 0.4)) {
            Task {
                await viewModel.addFoodItem(input: inputText)
                withAnimation(.easeOut(duration: 0.2)) {
                    inputText = ""
                }
            }
        }
    }
    
    private func handleEditSave(for item: FoodItem, editedText: String, imageData: Data?) async {
        await viewModel.updateFoodItem(
            originalItem: item,
            input: editedText,
            imageData: imageData
        )
    }
}

