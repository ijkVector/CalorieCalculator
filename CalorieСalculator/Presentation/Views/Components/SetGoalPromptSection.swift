//
//  SetGoalPromptSection.swift
//  CalorieСalculator
//
//  Created by Иван Дроботов on 11/24/25.
//

import SwiftUI

struct SetGoalPromptSection: View {
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                icon
                
                textContent
                
                Spacer()
                
                chevron
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
    
    // MARK: - Subviews
    
    private var icon: some View {
        ZStack {
            Circle()
                .fill(Color.blue.opacity(0.15))
                .frame(width: 50, height: 50)
            
            Image(systemName: "target")
                .font(.system(size: 24))
                .foregroundStyle(.blue)
        }
    }
    
    private var textContent: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Set Your Daily Goal")
                .font(.headline)
                .foregroundStyle(.primary)
            
            Text("Track your progress with a calorie target")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
    
    private var chevron: some View {
        Image(systemName: "chevron.right")
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(.tertiary)
    }
}

#Preview {
    VStack {
        SetGoalPromptSection {
            print("Goal tapped")
        }
        
        Spacer()
    }
}

