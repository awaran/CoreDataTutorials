//
//  ContentView.swift
//  Tutorial_04
//
//  Created by RJ Waran on 5/27/21.
//

import SwiftUI
import CoreData

struct ContentView: View {
  // Can put this in app delegate, need somewhere to init
  let mockNetworkManager = MockNetworkManager.shared

  @Environment(\.managedObjectContext) private var viewContext
  
  @FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \NetworkRequest.timestamp, ascending: true)],
    animation: .default)
  private var incompleteRequests: FetchedResults<NetworkRequest>
  
  var body: some View {
    List {
      ForEach(incompleteRequests) { curRequest in
        Text("curRequest at \(curRequest.timestamp!, formatter: itemFormatter) request:\(curRequest.request!)")
      }
      .onDelete(perform: deleteItems)
    }
    Button(action: addRequests) {
      Label("Add 10 requests", systemImage: "plus")
    }
    
    Button(action: deleteAllItems) {
      Label("Delete all requests", systemImage: "minus")
    }
  }
  
  private func addRequests() {
    PersistenceController.shared.container.performBackgroundTask { (backgroundContext) in
      for _ in 0 ..< 10 {
        let newNetworkRequest = NetworkRequest(context: backgroundContext)
        newNetworkRequest.timestamp = Date()
        newNetworkRequest.request = "request: rnd:\(Int.random(in: 1 ..< 99999)) date:\(String(describing: newNetworkRequest.timestamp))"
      }
      do {
        try backgroundContext.save()
      } catch {
        print("error saving to background")
      }
      
    }
  }
  private func deleteAllItems () {
    deleteItems(offsets: IndexSet(0 ..< incompleteRequests.count))
  }
  private func deleteItems(offsets: IndexSet) {
    withAnimation {
      offsets.map { incompleteRequests[$0] }.forEach(viewContext.delete)
      
      do {
        try viewContext.save()
      } catch {
        let nsError = error as NSError
        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
      }
    }
  }
  
  
}

private let itemFormatter: DateFormatter = {
  let formatter = DateFormatter()
  formatter.dateStyle = .short
  formatter.timeStyle = .medium
  return formatter
}()

