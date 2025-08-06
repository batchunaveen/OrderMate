//
//  OrdersView.swift
//  OrderMate
//
//  Created by Naveen on 8/4/25.
//

//
//  OrdersView.swift
//  OrderMate
//
//  Created by Naveen on 8/4/25.
//

import SwiftUI
import CoreData
import PDFKit
import UniformTypeIdentifiers

struct OrdersView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        entity: Order.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Order.createdAt, ascending: false)],
        animation: .default
    ) private var orders: FetchedResults<Order>

    @State private var showExporter = false
    @State private var pdfURL: URL?
    @State private var showNewOrderForm = false
    @State private var sortOption: SortOption = .dateDesc

    enum SortOption: String, CaseIterable, Identifiable {
        case nameAsc = "Name ↑"
        case nameDesc = "Name ↓"
        case dateAsc = "Date ↑"
        case dateDesc = "Date ↓"
        case amountAsc = "Amount ↑"
        case amountDesc = "Amount ↓"

        var id: String { self.rawValue }
    }

    var sortedOrders: [Order] {
        switch sortOption {
        case .nameAsc: return orders.sorted { ($0.name ?? "") < ($1.name ?? "") }
        case .nameDesc: return orders.sorted { ($0.name ?? "") > ($1.name ?? "") }
        case .dateAsc: return orders.sorted { ($0.createdAt ?? .distantPast) < ($1.createdAt ?? .distantPast) }
        case .dateDesc: return orders.sorted { ($0.createdAt ?? .distantPast) > ($1.createdAt ?? .distantPast) }
        case .amountAsc: return orders.sorted { $0.amount < $1.amount }
        case .amountDesc: return orders.sorted { $0.amount > $1.amount }
        }
    }

    var body: some View {
        ZStack {
            // Glassy pastel background for both modes
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(.systemIndigo).opacity(0.13),
                    Color(.systemBackground)
                ]),
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack {
                HStack {
                    Picker("Sort By", selection: $sortOption) {
                        ForEach(SortOption.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())

                    Spacer()

                    Button(action: exportToPDF) {
                        Label("Export PDF", systemImage: "square.and.arrow.up")
                    }
                    .buttonStyle(.bordered)

                    Button(action: {
                        showNewOrderForm = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                    .buttonStyle(.bordered)

                    Button(action: {
                        print("🗑️ Delete action placeholder")
                    }) {
                        Image(systemName: "trash.circle.fill").font(.title2)
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.horizontal)
                .padding(.top)

                Divider()

                ScrollView([.horizontal, .vertical]) {
                    LazyVStack(spacing: 8) {
                        // Table Header
                        HStack {
                            Text("Name").bold().frame(width: 120, alignment: .leading)
                            Text("Address").bold().frame(width: 180, alignment: .leading)
                            Text("Type").bold().frame(width: 80)
                            Text("Amount").bold().frame(width: 80)
                            Text("Date").bold().frame(width: 100)
                        }
                        .padding(.bottom, 4)
                        .glassCardBackground(cornerRadius: 12)
                        
                        Divider()

                        // Table Rows - now inline editable
                        ForEach(sortedOrders) { order in
                            EditableOrderRow(order: order)
                                .glassCardBackground(cornerRadius: 12)
                                .padding(.horizontal)
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Orders")
        .sheet(isPresented: $showNewOrderForm) {
            NewOrderFormStyled()
                .environment(\.managedObjectContext, viewContext)
        }
        .fileExporter(
            isPresented: $showExporter,
            document: pdfURL.map { PDFFile(url: $0) },
            contentType: .pdf,
            defaultFilename: "Orders"
        ) { _ in }
    }

    private func exportToPDF() {
        let pdfMetaData = [
            kCGPDFContextCreator: "OrderMate",
            kCGPDFContextAuthor: "OrderMateApp"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        let pageWidth = 595.2
        let pageHeight = 841.8
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight), format: format)
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("Orders-\(UUID().uuidString).pdf")

        do {
            try pdfRenderer.writePDF(to: url) { context in
                context.beginPage()
                var yOffset: CGFloat = 20

                for order in sortedOrders {
                    let text = """
                    Name: \(order.name ?? "")
                    Address: \(order.address ?? "")
                    Type: \(order.type ?? "")
                    Amount: $\(order.amount)
                    Date: \(order.createdAt ?? Date())

                    Items:
                    \(order.itemsArray.map { "- \($0.name ?? "") x\($0.quantity)" }.joined(separator: "\n"))

                    -------------------------------
                    """

                    let attrs: [NSAttributedString.Key: Any] = [
                        .font: UIFont.systemFont(ofSize: 12),
                        .paragraphStyle: {
                            let ps = NSMutableParagraphStyle()
                            ps.lineSpacing = 4
                            return ps
                        }()
                    ]

                    let attributedText = NSAttributedString(string: text, attributes: attrs)
                    let textRect = CGRect(x: 20, y: yOffset, width: pageWidth - 40, height: .greatestFiniteMagnitude)

                    let textHeight = attributedText.boundingRect(with: CGSize(width: pageWidth - 40, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil).height

                    if yOffset + textHeight > pageHeight - 40 {
                        context.beginPage()
                        yOffset = 20
                    }

                    attributedText.draw(in: textRect)
                    yOffset += textHeight + 20
                }
            }

            pdfURL = url
            showExporter = true
        } catch {
            print("❌ Failed to create PDF: \(error.localizedDescription)")
        }
    }
}

// MARK: - Editable Row View
struct EditableOrderRow: View {
    @ObservedObject var order: Order
    @Environment(\.managedObjectContext) var context

    @State private var name: String = ""
    @State private var address: String = ""
    @State private var type: String = ""
    @State private var amount: String = ""

    var body: some View {
        HStack {
            TextField("Name", text: $name).frame(width: 120)
            TextField("Address", text: $address).frame(width: 180)
            TextField("Type", text: $type).frame(width: 80)
            TextField("Amount", text: $amount).keyboardType(.decimalPad).frame(width: 80)
            Text(order.createdAt ?? Date(), style: .date).frame(width: 100)
        }
        .onAppear {
            name = order.name ?? ""
            address = order.address ?? ""
            type = order.type ?? ""
            amount = String(order.amount)
        }
        .onChange(of: name) { order.name = name; save() }
        .onChange(of: address) { order.address = address; save() }
        .onChange(of: type) { order.type = type; save() }
        .onChange(of: amount) {
            if let amt = Float(amount) {
                order.amount = amt
                save()
            }
        }
        .padding(.vertical, 6)
    }

    private func save() {
        try? context.save()
    }
}


// MARK: - Glass Card Modifier (for cards, rows, headers)
extension View {
    func glassCardBackground(cornerRadius: CGFloat = 12) -> some View {
        self.background(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(Color.white.opacity(0.10), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.12), radius: 7, x: 0, y: 4)
        )
    }
}

// MARK: - Helper
extension Order {
    var itemsArray: [OrderItem] {
        let set = items as? Set<OrderItem> ?? []
        return set.sorted { ($0.name ?? "") < ($1.name ?? "") }
    }
}
