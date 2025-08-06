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

    // Dashboard features with icons and light tints
    private let features: [(title: String, icon: String, destination: AnyView, tint: Color)] = [
        ("Orders", "cart", AnyView(OrdersView()), Color.purple.opacity(0.2)),
        ("Menu", "fork.knife", AnyView(MenuView()), Color.orange.opacity(0.2)),
        ("Reports", "chart.bar", AnyView(ReportsView()), Color.teal.opacity(0.2)),
        ("Locations", "map", AnyView(Text("Coming Soon")), Color.indigo.opacity(0.2)),
        ("Settings", "gear", AnyView(Text("Coming Soon")), Color.gray.opacity(0.2))
    ]

    private let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {

                    // Title
                    Text("Order Manager")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(colors: [.orange, .red],
                                           startPoint: .leading,
                                           endPoint: .trailing)
                        )
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 2, y: 2)
                        .padding(.top, 20)

                    // Cards Grid
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(features, id: \.title) { feature in
                            NavigationLink(destination: feature.destination) {
                                GlassCard(icon: feature.icon, title: feature.title, tint: feature.tint)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom)
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 250/255, green: 245/255, blue: 255/255),
                        Color(red: 235/255, green: 245/255, blue: 255/255)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
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
    var tint: Color

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(tint)
                        .blur(radius: 10)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 4)
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
