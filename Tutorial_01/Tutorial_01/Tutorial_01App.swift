//
//  Tutorial_01App.swift
//  Tutorial_01
//
//  Created by RJ Waran on 1/6/21.
//

import SwiftUI

@main
struct Tutorial_01App: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
