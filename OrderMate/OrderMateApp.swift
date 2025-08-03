//
//  OrderMateApp.swift
//  OrderMate
//
//  Created by Naveen on 8/3/25.
//

import SwiftUI

@main
struct OrderMateApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
