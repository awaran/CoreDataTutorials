//
//  Tutorial_04App.swift
//  Tutorial_04
//
//  Created by RJ Waran on 5/27/21.
//

import SwiftUI

@main
struct Tutorial_04App: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
