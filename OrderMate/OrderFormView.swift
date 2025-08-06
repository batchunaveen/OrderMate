//
//  OrderFormView.swift
//  OrderMate
//
//  Created by Naveen on 8/4/25.
//

// MARK: - OrderFormView
import CoreData
import SwiftUI

struct OrderFormView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    var orderToEdit: Order?

    @State private var name: String = ""
    @State private var address: String = ""
    @State private var quantity: Int = 1
    @State private var amount: Float = 0.0
    @State private var type: String = "online"

    private let orderTypes = ["online", "edi"]

    var body: some View {
        Form {
            Section(header: Text("Customer Info")) {
                TextField("Name", text: $name)
                TextField("Address", text: $address)
            }

            Section(header: Text("Order Details")) {
                Stepper(value: $quantity, in: 1...100) {
                    Text("Quantity: \(quantity)")
                }

                TextField("Amount ($)", value: $amount, format: .number)
                    .keyboardType(.decimalPad)

                Picker("Order Type", selection: $type) {
                    ForEach(orderTypes, id: \.self) {
                        Text($0.capitalized)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section {
                Button(orderToEdit == nil ? "Add Order" : "Update Order") {
                    saveOrder()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .navigationTitle(orderToEdit == nil ? "New Order" : "Edit Order")
        .onAppear {
            if let order = orderToEdit {
                name = order.name ?? ""
                address = order.address ?? ""
                quantity = Int(order.quantity)
                amount = Float(order.amount)
                type = order.type ?? "online"
            }
        }
    }

    private func saveOrder() {
        let order = orderToEdit ?? Order(context: viewContext)
        if orderToEdit == nil {
            order.id = UUID()
            order.createdAt = Date()
        }

        order.name = name
        order.address = address
        order.quantity = Int16(quantity)
        order.amount = Float(amount)
        order.type = type

        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("❌ Failed to save order:", error)
        }
    }
}
