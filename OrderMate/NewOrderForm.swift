//
//  NewOrderForm.swift
//  OrderMate
//
//  Created by Naveen on 8/4/25.
//

import SwiftUI

struct NewOrderForm: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var address = ""
    @State private var type = "online"
    @State private var amount = ""
    
    @State private var itemName = ""
    @State private var itemQuantity = ""
    @State private var items: [(String, Int)] = []

    let orderTypes = ["online", "edi"]

    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Text("New Order")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)

                VStack(spacing: 12) {
                    // Glass-style form container
                    Group {
                        TextField("Name", text: $name)
                        TextField("Address", text: $address)
                        Picker("Type", selection: $type) {
                            ForEach(orderTypes, id: \.self) {
                                Text($0.capitalized)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        TextField("Amount ($)", text: $amount)
                            .keyboardType(.decimalPad)
                    }
                    .textFieldStyle(.roundedBorder)
                }
                .padding(.horizontal)

                Divider()

                VStack(spacing: 10) {
                    HStack {
                        TextField("Item Name", text: $itemName)
                        TextField("Qty", text: $itemQuantity)
                            .keyboardType(.numberPad)
                        Button {
                            addItem()
                        } label: {
                            Image(systemName: "plus.circle.fill")
                        }
                        .disabled(itemName.isEmpty || Int(itemQuantity) == nil)
                    }
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)

                    VStack(alignment: .leading) {
                        ForEach(items.indices, id: \.self) { index in
                            HStack {
                                Text("• \(items[index].0)")
                                Spacer()
                                Text("Qty: \(items[index].1)")
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                Button(action: saveOrder) {
                    Label("Save Order", systemImage: "checkmark.circle.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                }
                .disabled(!isFormValid)
                .padding()

                Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(.red)
                .padding(.bottom)
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(25)
            .padding(.horizontal, 20)
            .shadow(radius: 15)
        }
    }

    private var isFormValid: Bool {
        !name.isEmpty && !address.isEmpty && Double(amount) != nil && !items.isEmpty
    }

    private func addItem() {
        if let qty = Int(itemQuantity), !itemName.isEmpty {
            items.append((itemName, qty))
            itemName = ""
            itemQuantity = ""
        }
    }

    private func saveOrder() {
        let order = Order(context: viewContext)
        order.id = UUID()
        order.name = name
        order.address = address
        order.type = type
        order.amount = Float(amount) ?? 0
        order.createdAt = Date()

        for (name, qty) in items {
            let item = OrderItem(context: viewContext)
            item.name = name
            item.quantity = Int16(qty)
            item.order = order
        }

        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("❌ Failed to save order: \(error.localizedDescription)")
        }
    }
}
