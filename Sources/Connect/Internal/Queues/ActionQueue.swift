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

internal enum ConcurrencyMode {
    case serial
    case concurrent
}

internal class ActionQueue {
    
    fileprivate let queue: OperationQueue
    
    public init(label: String, concurrencyMode mode: ConcurrencyMode = .serial) {

        self.label = label
        self.concurrencyMode = mode

        queue = OperationQueue()
        queue.name = label

        switch (concurrencyMode) {
            case .serial:     queue.maxConcurrentOperationCount = 1
            case .concurrent: queue.maxConcurrentOperationCount = 5
        }
    }

    public let label: String

    public let concurrencyMode: ConcurrencyMode

    public var isSuspended: Bool {
        get {
            return self.queue.isSuspended
        }
        set {
            self.queue.isSuspended = newValue
        }
    }

    public func cancelAllActions() {
        self.queue.cancelAllOperations()
    }

    public func waitUntilAllActionsAreFinished() {
        self.queue.waitUntilAllOperationsAreFinished()
    }

    public func addAction<T: Operation>(_ action: T, waitUntilDone wait: Bool = false) {
        self.queue.addOperations([action], waitUntilFinished: wait)
    }
}

extension ActionQueue: CustomStringConvertible {

    public var description: String {
        return "\(type(of: self)) (name: \(self.label), concurrencyMode: \(self.concurrencyMode))"
    }
}
