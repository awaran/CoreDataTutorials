//
//  Tutorial_02App.swift
//  Tutorial_02
//
//  Created by RJ Waran on 1/6/21.
//

import SwiftUI

@main
struct Tutorial_02App: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
