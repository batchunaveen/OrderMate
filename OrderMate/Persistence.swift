//
//  Persistence.swift
//  OrderMate
//
//  Created by Naveen on 8/3/25.
//

//MARK: - PersistenceController
import Foundation
import CoreData
import CoreTransferable

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext

        // You can optionally create a dummy Order here if needed
        /*
        let order = Order(context: viewContext)
        order.name = "Sample"
        order.address = "123 Food St"
        order.type = "online"
        order.amount = 45.50
        order.createdAt = Date()

        let item = OrderItem(context: viewContext)
        item.name = "Butter Naan"
        item.quantity = 2
        item.order = order
        */

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }

        return result
    }()


    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "OrderMate")

        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
