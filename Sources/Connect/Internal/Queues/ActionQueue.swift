//
//  ActionQueue.swift
//  Pods
//
//  Created by Tony Stone on 8/22/16.
//
//

import Foundation
import TraceLog
import CoreData

internal
class ActionQueue {
    
    internal
    enum Mode {
        case serial
        case concurrent
    }
    
    fileprivate let queue: OperationQueue
    
    internal
    init(name: String, concurrencyMode: Mode) {
        
        queue = OperationQueue()
        queue.name = name
        
        switch (concurrencyMode) {
            case .serial:     queue.maxConcurrentOperationCount = 1
            case .concurrent: queue.maxConcurrentOperationCount = 5
        }
        
        logTrace(1) { "Created queue \(name)" }
    }
    
    internal
    func suspend() {
        queue.isSuspended = true
    }
    
    internal
    func resume() {
        queue.isSuspended = false
    }
    
    internal
    func addAction<T: NSManagedObject>(_ action: EntityAction<T>, waitUntilDone wait: Bool) {
    
        //
        // Register the operation first so the users get notifications
        //
        // [MGActionNotificationService registerActionForNotification: anAction];
    
        queue.addOperations([action], waitUntilFinished: wait)
    }
    
    internal
    var actions: [AnyObject] {
        get {
            return queue.operations
        }
    }
}
