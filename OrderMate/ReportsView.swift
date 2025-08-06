//
//  ReportsView.swift
//  OrderMate
//
//  Created by Naveen on 8/4/25.
//

// MARK: - ReportsView
import Foundation
import SwiftUI
import CoreData

struct ReportsView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Order.createdAt, ascending: false)],
        animation: .default
    )
    private var orders: FetchedResults<Order>

    var totalOrders: Int {
        orders.count
    }

    var latestDate: Date? {
        orders.first?.createdAt
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Reports")
                .font(.largeTitle)
                .bold()

            HStack(spacing: 30) {
                ReportMetric(title: "Total Orders", value: "\(totalOrders)")
                if let date = latestDate {
                    ReportMetric(title: "Latest Order", value: date.formatted(date: .abbreviated, time: .omitted))
                }
            }

            Spacer()
        }
        .padding()
    }
}

struct ReportMetric: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title2)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(15)
    }
}
