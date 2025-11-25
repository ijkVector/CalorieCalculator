//
//  FoodItemRow.swift
//  CalorieСalculator
//
//  Created by Иван Дроботов on 11/24/25.
//

import SwiftUI

struct FoodItemRow: View {
    let item: FoodItem
    @State private var isAppearing = false
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            itemImage
                .scaleEffect(isAppearing ? 1.0 : 0.8)
                .opacity(isAppearing ? 1.0 : 0.0)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                    .opacity(isAppearing ? 1.0 : 0.0)
                    .offset(x: isAppearing ? 0 : -20)
                
                Text(item.timestamp, style: .time)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .opacity(isAppearing ? 1.0 : 0.0)
                    .offset(x: isAppearing ? 0 : -20)
            }
            
            Spacer()
            
            calorieInfo
                .scaleEffect(isAppearing ? 1.0 : 0.8)
                .opacity(isAppearing ? 1.0 : 0.0)
        }
        .padding(.vertical, 4)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5).delay(0.05)) {
                isAppearing = true
            }
        }
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var itemImage: some View {
        if let imageData = item.imageData,
           let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                .transition(.scale.combined(with: .opacity))
        } else {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay {
                    Image(systemName: "fork.knife")
                        .foregroundStyle(.gray)
                        .symbolEffect(.pulse, options: .repeating)
                }
                .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
        }
    }
    
    private var calorieInfo: some View {
        HStack(spacing: 4) {
            Text("\(item.calories)")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.blue)
                .contentTransition(.numericText())
            
            Text("kcal")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.blue.opacity(0.1))
        )
    }
}

#Preview {
    List {
        FoodItemRow(
            item: FoodItem(
                name: "Apple",
                calories: 52
            )
        )
        
        FoodItemRow(
            item: FoodItem(
                name: "Grilled Chicken Breast",
                calories: 165
            )
        )
    }
}

