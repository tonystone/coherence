///
///  ActionQueue.swift
///
///  Copyright 2016 Tony Stone
///
///  Licensed under the Apache License, Version 2.0 (the "License");
///  you may not use this file except in compliance with the License.
///  You may obtain a copy of the License at
///
///  http://www.apache.org/licenses/LICENSE-2.0
///
///  Unless required by applicable law or agreed to in writing, software
///  distributed under the License is distributed on an "AS IS" BASIS,
///  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
///  See the License for the specific language governing permissions and
///  limitations under the License.
///
///  Created by Tony Stone on 8/22/16.
///
import Foundation
import TraceLog
import CoreData

internal class ActionQueue {
    
    public enum Mode {
        case serial
        case concurrent
    }
    
    fileprivate let queue: OperationQueue
    
    public init(name: String, concurrencyMode: Mode) {
        
        queue = OperationQueue()
        queue.name = name
        
        switch (concurrencyMode) {
            case .serial:     queue.maxConcurrentOperationCount = 1
            case .concurrent: queue.maxConcurrentOperationCount = 5
        }
    }
    
    public func suspend() {
        queue.isSuspended = true
    }
    
    public func resume() {
        queue.isSuspended = false
    }
    
    public func addAction<T: Operation>(_ action: T, waitUntilDone wait: Bool) {
    
        queue.addOperations([action], waitUntilFinished: wait)
    }
    
    public var actions: [AnyObject] {
        get {
            return queue.operations
        }
    }
}

extension ActionQueue: CustomStringConvertible, CustomDebugStringConvertible {

    public var description: String {
        return "\(type(of: self)) (\(self.queue.name ?? "unknown"))"
    }

    public var debugDescription: String {
        return self.description
    }
}
