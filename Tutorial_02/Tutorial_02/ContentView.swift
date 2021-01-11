//
//  ContentView.swift
//  Tutorial_02
//
//  Created by RJ Waran on 1/6/21.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>

    var body: some View {
        List {
            ForEach(items) { item in
              Text("Item at \(item.timestamp!, formatter: itemFormatter) rnd:\(item.rnd)")
            }
            .onDelete(perform: deleteItems)
        }
      Button(action: addItem) {
          Label("Add 10 Items", systemImage: "plus")
      }
                  
      Button(action: deleteAllItems) {
          Label("Delete all Items", systemImage: "minus")
      }
    }

    private func addItem() {
      DispatchQueue.global(qos: .background).async {
        for _ in 0 ..< 1000 {
          let newItem = Item(context: viewContext)
          newItem.timestamp = Date()
          newItem.rnd = Int64(Int.random(in: 1 ..< 99999))
//          sleep(1)
        }
          do {
              try viewContext.save()
          } catch {
              // Replace this implementation with code to handle the error appropriately.
              // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
              let nsError = error as NSError
              fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
          }
      }
      DispatchQueue.main.async {
        for curItem in items {
          curItem.rnd = Int64(Int.random(in: 1 ..< 99999))
        }
      }
    }
  
  private func deleteAllItems () {
    deleteItems(offsets: IndexSet(0 ..< items.count))
  }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
          
          offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
