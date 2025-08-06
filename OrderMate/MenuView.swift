//
//  MenuView.swift
//  OrderMate
//
//  Created by Naveen on 8/4/25.
//

// MARK: - MenuView
import SwiftUI

struct MenuItem: Identifiable {
    let id = UUID()
    let name: String
    let price: Double
    let icon: String
}

struct MenuView: View {
    private let menuItems: [MenuItem] = [
        .init(name: "Paneer Butter Masala", price: 12.99, icon: "🥘"),
        .init(name: "Chicken Biryani", price: 14.49, icon: "🍗"),
        .init(name: "Masala Dosa", price: 9.99, icon: "🌯"),
        .init(name: "Butter Naan", price: 3.99, icon: "🍞"),
        .init(name: "Gulab Jamun", price: 5.49, icon: "🍮"),
        .init(name: "Tandoori Chicken", price: 15.99, icon: "🔥"),
        .init(name: "Veg Thali", price: 13.49, icon: "🍛")
    ]

    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(menuItems) { item in
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                        .frame(height: 120)
                        .overlay(
                            VStack(spacing: 8) {
                                Text(item.icon)
                                    .font(.largeTitle)
                                Text(item.name)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text("$\(String(format: "%.2f", item.price))")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        )
                }
            }
            .padding()
        }
        .navigationTitle("Menu")
    }
}
