//
//  QuickGoalButton.swift
//  CalorieСalculator
//
//  Created by Иван Дроботов on 11/24/25.
//

import SwiftUI

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

#Preview {
    @Previewable @State var goalText = ""
    
    LazyVGrid(columns: [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ], spacing: 8) {
        QuickGoalButton(value: 1500, goalText: $goalText)
        QuickGoalButton(value: 2000, goalText: $goalText)
        QuickGoalButton(value: 2500, goalText: $goalText)
    }
    .padding()
}

