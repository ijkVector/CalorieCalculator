//
//  TotalCaloriesSection.swift
//  CalorieСalculator
//
//  Created by Иван Дроботов on 11/24/25.
//

import SwiftUI

struct TotalCaloriesSection: View {
    let totalCalories: Int
    
    @State private var animatedCalories: Int = 0
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: 8) {
            Divider()
            
            HStack {
                Text("Total Calories")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Text("\(animatedCalories)")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                    .contentTransition(.numericText())
                    .scaleEffect(scale)
                
                Text("kcal")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 8)
            }
            .padding()
        }
        .background(
            RoundedRectangle(cornerRadius: 0)
                .fill(Color(.secondarySystemBackground))
        )
        .onChange(of: totalCalories) { oldValue, newValue in
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                animatedCalories = newValue
            }
            
            // Pulse effect when calories change
            withAnimation(.easeInOut(duration: 0.2)) {
                scale = 1.15
            }
            withAnimation(.easeInOut(duration: 0.2).delay(0.2)) {
                scale = 1.0
            }
        }
        .onAppear {
            animatedCalories = totalCalories
        }
    }
}

#Preview {
    VStack {
        Spacer()
        
        TotalCaloriesSection(totalCalories: 1250)
    }
}

