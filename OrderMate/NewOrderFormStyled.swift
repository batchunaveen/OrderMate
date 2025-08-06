import SwiftUI

struct NewOrderFormStyled: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var address = ""
    @State private var type = "online"
    @State private var amount: Float = 0
    @State private var items: [OrderItemInput] = [OrderItemInput()]

    private let orderTypes = ["online", "catering"]

    var tint: Color = Color.purple.opacity(0.2) // use same as in Orders

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
            
            VStack(spacing: 20) {
                Text("New Order")
                    .font(.title)
                    .bold()
                    .foregroundColor(.primary)

                Form {
                    Section(header: Text("Order Details")) {
                        TextField("Name", text: $name)
                        TextField("Address", text: $address)

                        Picker("Order Type", selection: $type) {
                            ForEach(orderTypes, id: \.self) { type in
                                Text(type.capitalized)
                            }
                        }

                        TextField("Amount", value: $amount, format: .number)
                            .keyboardType(.decimalPad)
                    }

                    Section(header: Text("Items")) {
                        ForEach($items.indices, id: \.self) { index in
                            HStack {
                                TextField("Item Name", text: $items[index].name)
                                TextField("Qty", value: $items[index].quantity, format: .number)
                                    .keyboardType(.numberPad)
                            }
                        }

                        Button(action: {
                            items.append(OrderItemInput())
                        }) {
                            Label("Add Item", systemImage: "plus")
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color.clear)

                Button(action: saveOrder) {
                    Label("Save Order", systemImage: "checkmark.circle")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.thinMaterial)
                        .cornerRadius(12)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal)
            }
            .padding()
        }
        .padding()
    }

    // MARK: Save Logic
    private func saveOrder() {
        let order = Order(context: viewContext)
        order.id = UUID()
        order.name = name
        order.address = address
        order.amount = amount
        order.type = type
        order.createdAt = Date()

        for itemInput in items where !itemInput.name.isEmpty {
            let item = OrderItem(context: viewContext)
            item.name = itemInput.name
            item.quantity = Int16(itemInput.quantity)
            item.order = order
        }

        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("❌ Error saving order: \(error.localizedDescription)")
        }
    }
}

// Simple input struct for adding items
struct OrderItemInput {
    var name: String = ""
    var quantity: Int = 1
}
