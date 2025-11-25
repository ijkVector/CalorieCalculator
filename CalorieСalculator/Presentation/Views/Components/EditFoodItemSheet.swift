//
//  EditFoodItemSheet.swift
//  CalorieСalculator
//
//  Created by Иван Дроботов on 11/25/25.
//

import SwiftUI
import PhotosUI

struct EditFoodItemSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    let item: FoodItem
    let onSave: (String, Data?) -> Void
    
    @State private var editedText: String
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var selectedImageData: Data?
    
    init(item: FoodItem, onSave: @escaping (String, Data?) -> Void) {
        self.item = item
        self.onSave = onSave
        // Initialize with current values
        _editedText = State(initialValue: "\(item.name) \(item.calories)")
        _selectedImageData = State(initialValue: item.imageData)
    }
    
    var body: some View {
        let hasImage = selectedImageData != nil
        
        NavigationStack {
            VStack(spacing: 16) {
                // Image section
                VStack(spacing: 8) {
                    if let imageData = selectedImageData,
                       let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    } else {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 120, height: 120)
                            .overlay {
                                Image(systemName: "photo")
                                    .font(.largeTitle)
                                    .foregroundStyle(.gray)
                            }
                    }
                    
                    PhotosPicker(
                        selection: $selectedPhoto,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        Label(
                            hasImage ? "Change Photo" : "Add Photo",
                            systemImage: hasImage ? "arrow.triangle.2.circlepath" : "photo"
                        )
                        .font(.subheadline)
                    }
                    .onChange(of: selectedPhoto) { _, newValue in
                        Task { @MainActor in
                            if let data = try? await newValue?.loadTransferable(type: Data.self) {
                                selectedImageData = data
                            }
                        }
                    }
                    
                    if hasImage {
                        Button(role: .destructive) {
                            selectedImageData = nil
                            selectedPhoto = nil
                        } label: {
                            Label("Remove Photo", systemImage: "trash")
                                .font(.subheadline)
                        }
                    }
                }
                .padding(.top, 20)
                
                // Text input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Food & Calories")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    TextField("e.g., Apple 52", text: $editedText, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(1...5)
                    
                    Text("Format: Name Calories (e.g., \"Apple 52\")")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("Edit Food Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(editedText, selectedImageData)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(editedText.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

#Preview {
    EditFoodItemSheet(
        item: FoodItem(name: "Apple", calories: 52)
    ) { text, imageData in
        print("Edited: \(text)")
    }
}

