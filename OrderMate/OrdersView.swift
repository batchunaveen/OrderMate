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
    )
    private var orders: FetchedResults<Order>

    @State private var showExporter = false
    @State private var pdfURL: URL?

    var body: some View {
        VStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    ForEach(orders) { order in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(order.name ?? "Unknown")
                                .font(.headline)

                            Text("Address: \(order.address ?? "N/A")")
                            Text("Order Type: \(order.type ?? "-")")
                            Text("Amount: $\(order.amount, specifier: "%.2f")")
                            Text("Date: \(order.createdAt ?? Date(), style: .date)")

                            Divider()

                            Text("Items:")
                                .font(.subheadline)
                                .bold()

                            ForEach(order.itemsArray, id: \.self) { item in
                                HStack {
                                    Text("• \(item.name ?? "")")
                                    Spacer()
                                    Text("Qty: \(item.quantity)")
                                }
                                .font(.callout)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(.secondarySystemBackground))
                        )
                    }
                }
                .padding()
            }

            Button(action: exportToPDF) {
                Label("Export Orders to PDF", systemImage: "square.and.arrow.up")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
        .navigationTitle("Orders")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: {
                    // Call addOrder()
                    addOrder()
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }

                Button(action: {
                    // Toggle delete mode (you can implement selection)
                    print("🔴 Delete mode triggered")
                }) {
                    Image(systemName: "trash.circle.fill")
                        .font(.title2)
                }
            }
        }
        .fileExporter(
            isPresented: $showExporter,
            document: pdfURL.map { PDFFile(url: $0) },
            contentType: .pdf,
            defaultFilename: "Orders"
        ) { result in
            // Handle result if needed
        }
    }

    // MARK: - PDF Export Logic
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

                for order in orders {
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

                    let paragraphStyle = NSMutableParagraphStyle()
                    paragraphStyle.lineSpacing = 4

                    let attrs: [NSAttributedString.Key: Any] = [
                        .font: UIFont.systemFont(ofSize: 12),
                        .paragraphStyle: paragraphStyle
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



// MARK: - Order Helper
extension Order {
    var itemsArray: [OrderItem] {
        let set = items as? NSSet ?? []
        return set.compactMap { $0 as? OrderItem }.sorted { ($0.name ?? "") < ($1.name ?? "") }
    }
}
