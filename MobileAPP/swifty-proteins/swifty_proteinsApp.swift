//
//  swifty_proteinsApp.swift
//  swifty-proteins
//
//  Created by XPI-9 on 8/8/2026.
//

import SwiftUI
import CoreData

@main
struct swifty_proteinsApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
