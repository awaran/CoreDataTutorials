//
//  MockNetworkManager.swift
//  Tutorial_04
//
//  Created by RJ Waran on 5/27/21.
//

import Foundation
import CoreData

// Usage: Extend AutoFetchParentClass and put in the custom coredata object as the type.
// I.E Replace NetworkRequest with BluetoothRequest or WorkQueueRequest.
// Note: Be sure to create the object in coredata before you run it.
class MockNetworkManager: AutoFetchParentClass<NetworkRequest> {
  static let shared = MockNetworkManager()
  var curNetworkRequest: NetworkRequest?
  init() {
    super.init(persistenceController: PersistenceController.shared, sortKey: "timestamp", order: .ascending)
  }
  
  override func doWork(queuedValues: [NetworkRequest]) {
    if curNetworkRequest == nil,
       let firstInQueue = queuedValues.first {
      curNetworkRequest = firstInQueue
      // Pretending we're doing request to server and saving data to coredata.
      print("doing work on network request: \(curNetworkRequest?.request)")
      Thread.sleep(forTimeInterval: Double.random(in: (0.0 ... 1.0)))
      self.saveCompletedRequest(networkRequest: firstInQueue)
      self.removeFromQueue(firstInQueue)
      curNetworkRequest = nil
    }
  }
  
  public func saveCompletedRequest(networkRequest: NetworkRequest) {
    let completedRequest = CompletedNetworkRequest(context: self.queueContext)
    completedRequest.timestampCompleted = Date()
    completedRequest.timestampRequested = networkRequest.timestamp
    completedRequest.request = networkRequest.request
  }
  
}
