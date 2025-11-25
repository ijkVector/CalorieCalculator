//
//  FoodInputSection.swift
//  CalorieСalculator
//
//  Created by Иван Дроботов on 11/24/25.
//

import SwiftUI
import PhotosUI

struct FoodInputSection: View {
    @Binding var inputText: String
    @Binding var selectedPhoto: PhotosPickerItem?
    @Binding var selectedImageData: Data?
    
    let onAdd: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                textInputSection
                addButton
            }
            
            if selectedImageData != nil {
                selectedPhotoPreview
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .onChange(of: selectedPhoto) { _, newValue in
            Task { @MainActor in
                if let data = try? await newValue?.loadTransferable(type: Data.self) {
                    selectedImageData = data
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    private var textInputSection: some View {
        HStack(spacing: 8) {
            TextField("Enter food (e.g., Apple 52)", text: $inputText)
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()
            
            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                Image(systemName: "photo")
                    .font(.system(size: 20))
                    .foregroundStyle(.blue)
                    .frame(width: 44, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.blue.opacity(0.1))
                    )
            }
        }
    }
    
    private var addButton: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                onAdd()
            }
        }) {
            Text("Add")
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(inputText.isEmpty ? Color.gray : Color.blue)
                )
                .scaleEffect(inputText.isEmpty ? 0.95 : 1.0)
        }
        .disabled(inputText.isEmpty)
        .animation(.easeInOut(duration: 0.2), value: inputText.isEmpty)
    }
    
    @ViewBuilder
    private var selectedPhotoPreview: some View {
        if let imageData = selectedImageData,
           let uiImage = UIImage(data: imageData) {
            HStack {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Photo selected")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Text("Will be attached to the item")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                
                Spacer()
                
                Button {
                    withAnimation(.easeOut(duration: 0.3)) {
                        selectedPhoto = nil
                        selectedImageData = nil
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.gray)
                        .symbolEffect(.bounce, value: selectedImageData)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
            )
            .transition(.asymmetric(
                insertion: .scale.combined(with: .opacity),
                removal: .scale(scale: 0.8).combined(with: .opacity)
            ))
        }
    }
}

#Preview {
    @Previewable @State var inputText = "Apple 52"
    @Previewable @State var selectedPhoto: PhotosPickerItem? = nil
    @Previewable @State var selectedImageData: Data? = nil
    
    VStack {
        FoodInputSection(
            inputText: $inputText,
            selectedPhoto: $selectedPhoto,
            selectedImageData: $selectedImageData,
            onAdd: {
                print("Add tapped")
            }
        )
        
        Spacer()
    }
}

