//
//  ContentView.swift
//  OrderMate
//
//  Created by Naveen on 8/3/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    private let features: [(title: String, icon: String, destination: AnyView)] = [
        ("Orders", "cart", AnyView(OrdersView())),
        ("Menu", "fork.knife", AnyView(MenuView())),
        ("Reports", "chart.bar", AnyView(ReportsView())),
        ("Locations", "map", AnyView(Text("Coming Soon"))),
        ("Settings", "gear", AnyView(Text("Coming Soon")))
    ]

    private let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {

                    // 🌟 Title: Order Manager
                    Text("Order Manager")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(colors: [.orange, .red],
                                           startPoint: .leading,
                                           endPoint: .trailing)
                        )
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 2, y: 2)
                        .padding(.top, 20)

                    // 💠 Feature Cards Grid
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(features, id: \.title) { feature in
                            NavigationLink(destination: feature.destination) {
                                GlassCard(icon: feature.icon, title: feature.title)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom)
            }
            .background(
                LinearGradient(colors: [Color(.systemBackground), Color(.systemGray6)],
                               startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            )
            .navigationBarHidden(true)
        }
    }
}

// MARK: - GlassCard View

struct GlassCard: View {
    var icon: String
    var title: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(Color.white.opacity(0.25), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
                .frame(height: 140)

            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundColor(.primary)

                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
            }
        }
        .padding(.horizontal, 4)
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
