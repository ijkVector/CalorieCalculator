//
//  GoalProgressSection.swift
//  CalorieСalculator
//
//  Created by Иван Дроботов on 11/24/25.
//

import SwiftUI

struct GoalProgressSection: View {
    let goal: CalorieGoal
    let totalCalories: Int
    let remainingCalories: Int
    let goalProgress: Double
    let isGoalExceeded: Bool
    
    @State private var animatedProgress: Double = 0
    @State private var animatedCalories: Int = 0
    @State private var animatedRemaining: Int = 0
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                goalInfo
                    .transition(.scale.combined(with: .opacity))
                
                Spacer()
                
                remainingInfo
                    .transition(.scale.combined(with: .opacity))
            }
            
            progressBar
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
        )
        .onAppear {
            animateValues()
        }
        .onChange(of: totalCalories) { _, _ in
            animateValues()
        }
        .onChange(of: goalProgress) { _, _ in
            animateValues()
        }
    }
    
    private func animateValues() {
        withAnimation(.easeOut(duration: 0.6)) {
            animatedProgress = goalProgress
            animatedCalories = totalCalories
            animatedRemaining = remainingCalories
        }
    }
    
    // MARK: - Subviews
    
    private var goalInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Daily Goal")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Text("\(goal.dailyCalorieTarget) kcal")
                .font(.headline)
                .foregroundStyle(.primary)
        }
    }
    
    private var remainingInfo: some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text(isGoalExceeded ? "Exceeded" : "Remaining")
                .font(.caption)
                .foregroundStyle(.secondary)
                .animation(.easeInOut, value: isGoalExceeded)
            
            Text("\(animatedRemaining) kcal")
                .font(.headline)
                .foregroundStyle(isGoalExceeded ? .red : .green)
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: 0.4), value: animatedRemaining)
        }
    }
    
    private var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.15))
                    .frame(height: 24)
                
                // Progress with gradient
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        LinearGradient(
                            colors: [progressBarColor, progressBarColor.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(
                        width: max(0, min(geometry.size.width * animatedProgress, geometry.size.width)),
                        height: 24
                    )
                    .shadow(color: progressBarColor.opacity(0.3), radius: 2, x: 0, y: 1)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: animatedProgress)
                
                // Percentage text
                Text("\(Int(animatedProgress * 100))%")
                    .font(.caption.bold())
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.5), value: animatedProgress)
            }
        }
        .frame(height: 24)
    }
    
    private var progressBarColor: Color {
        let progress = goalProgress
        
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
}

#Preview {
    VStack(spacing: 20) {
        GoalProgressSection(
            goal: CalorieGoal(dailyCalorieTarget: 2000),
            totalCalories: 500,
            remainingCalories: 1500,
            goalProgress: 0.25,
            isGoalExceeded: false
        )
        
        GoalProgressSection(
            goal: CalorieGoal(dailyCalorieTarget: 2000),
            totalCalories: 1600,
            remainingCalories: 400,
            goalProgress: 0.8,
            isGoalExceeded: false
        )
        
        GoalProgressSection(
            goal: CalorieGoal(dailyCalorieTarget: 2000),
            totalCalories: 2500,
            remainingCalories: 0,
            goalProgress: 1.25,
            isGoalExceeded: true
        )
    }
    .padding()
}

