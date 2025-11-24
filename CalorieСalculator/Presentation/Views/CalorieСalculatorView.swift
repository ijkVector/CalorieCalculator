//
//  ContentView.swift
//  CalorieСalculator
//
//  Created by Иван Дроботов on 11/23/25.
//

import SwiftUI
import SwiftData

struct CalorieСalculatorView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [FoodItemEntity]
    
    var body: some View {
        NavigationSplitView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
                    } label: {
                        Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
                    }
                }
            }
            .navigationTitle("Today's Meals")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        } detail: {
            Text("Select an item")
        }
    }
    
    private func addItem() {
        withAnimation {
            let newItem = FoodItemEntity(name: "Яблоко", calories: 100)
            modelContext.insert(newItem)
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}


//#Preview {
//    ContentView()
//        .modelContainer(for: Item.self, inMemory: true)
//}
