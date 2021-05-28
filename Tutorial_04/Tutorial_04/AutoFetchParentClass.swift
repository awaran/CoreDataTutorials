//
//  AutoFetchParentClass.swift
//  Tutorial_04
//
//  Created by RJ Waran on 5/27/21.
//

import CoreData
import Foundation

open class AutoFetchParentClass<T: NSManagedObject>: NSObject, NSFetchedResultsControllerDelegate {
  private let fetchController: NSFetchedResultsController<T>
  let persistenceController: PersistenceController
  var semaphore = DispatchSemaphore(value: 1)

  var queueContext: NSManagedObjectContext {
    return persistenceController.queueContext
  }
  
  init(persistenceController: PersistenceController, sortKey: String? = nil, order: AutoFetchOrderFormat = .unspecified) {
    
    self.persistenceController = persistenceController

    let typeName = String(describing: T.self)
    let fetchRequest = NSFetchRequest<T>(entityName: typeName)

    if let unwrappedSortKey = sortKey {
      var ascending = true
      if order == .descending {
        ascending = false
      }
      fetchRequest.sortDescriptors = [NSSortDescriptor(key: unwrappedSortKey, ascending: ascending)]
    }
    fetchController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                 managedObjectContext: self.persistenceController.getQueueContext(),
                                                 sectionNameKeyPath: nil, cacheName: nil)
    super.init()
    fetchController.delegate = self
    do {
      try fetchController.performFetch()
      let values = fetchController.fetchedObjects ?? []
      for curVal in values {
        print("initfetch: \(curVal)")
      }
    } catch {
      //self.dbController.logger?.error("LocalDB wrapper: init: \(error)")
      print("errror doing init fetch")
    }

  }
  
  // Can override but isn't recommended.
  public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    guard let queuedValues = controller.fetchedObjects as? [T],
          queuedValues.count > 0
    else { return }
    semaphore.wait()
    self.doWork(queuedValues: queuedValues)
    semaphore.signal()

    // BUG: sometimes get save recursive call and update to main thread doesn't happen till the end :(
    // Can't call save recursively in this function.  Update main thread on another thread.
    DispatchQueue.global(qos: .background).async { [weak self] in
      self?.save()
    }
  }
  
  public func removeFromQueue(_ item: T) {
    queueContext.delete(item)
  }
  
  public func save() {
    do {
      try queueContext.save()
    } catch {
        print("Error: there was a problem saving to disk \(error)")
    }
  }
  
  // When subclassing, you should override this.
  open func doWork(queuedValues: [T]) {
    fatalError("Override this function to take in objects when fetch changes.")
  }
}

public enum AutoFetchOrderFormat {
  case unspecified
  case ascending
  case descending
}
