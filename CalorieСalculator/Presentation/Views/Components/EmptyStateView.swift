//
//  EmptyStateView.swift
//  CalorieСalculator
//
//  Created by Иван Дроботов on 11/24/25.
//

import SwiftUI

struct EmptyStateView: View {
    @State private var isAnimating = false
    @State private var textOpacity: Double = 0
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: "fork.knife.circle")
                .font(.system(size: 60))
                .foregroundStyle(.gray)
                .symbolEffect(.bounce, value: isAnimating)
                .scaleEffect(isAnimating ? 1.0 : 0.5)
                .opacity(isAnimating ? 1.0 : 0.0)
            
            Text("No meals added yet")
                .font(.title3)
                .foregroundStyle(.secondary)
                .opacity(textOpacity)
                .offset(y: textOpacity == 1 ? 0 : 20)
            
            Text("Add your first meal above")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
                .opacity(textOpacity)
                .offset(y: textOpacity == 1 ? 0 : 20)
            
            Spacer()
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                isAnimating = true
            }
            withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
                textOpacity = 1
            }
        }
    }
}

#Preview {
    EmptyStateView()
}

