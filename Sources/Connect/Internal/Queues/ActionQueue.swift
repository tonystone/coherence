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

    fileprivate let dispatchQueue:  DispatchQueue
    fileprivate let operationQueue: OperationQueue

    public init(label: String, qos: DispatchQoS, concurrencyMode mode: ConcurrencyMode = .serial, suspended: Bool = false) {

        self.concurrencyMode = mode

        var queueAttributes = DispatchQueue.Attributes(rawValue: UInt64(0))

        if mode == .concurrent {
            queueAttributes.insert(.concurrent)
        }

        self.dispatchQueue = DispatchQueue(label: label, qos: qos, attributes: queueAttributes, autoreleaseFrequency: .inherit)

        operationQueue = OperationQueue()
        self.operationQueue.underlyingQueue = self.dispatchQueue

        operationQueue.name = label
        self.operationQueue.isSuspended = suspended

        switch (concurrencyMode) {
            case .serial:     self.operationQueue.maxConcurrentOperationCount = 1; break
            case .concurrent: self.operationQueue.maxConcurrentOperationCount = 5; break
        }
    }

    public var label: String {
        return self.dispatchQueue.label
    }

    public var concurrencyMode: ConcurrencyMode

    public var suspended: Bool {
        get {
            return self.operationQueue.isSuspended
        }
        set {
            self.operationQueue.isSuspended = newValue
        }
    }

    public func cancelAllActions() {
        self.operationQueue.cancelAllOperations()
    }

    public func waitUntilAllActionsAreFinished() {
        self.operationQueue.waitUntilAllOperationsAreFinished()
    }

    public func addAction<T: Operation>(_ action: T, waitUntilDone wait: Bool = false) {
        self.operationQueue.addOperations([action], waitUntilFinished: wait)
    }
}

extension ActionQueue: CustomStringConvertible {

    public var description: String {
        return "\(type(of: self)) (name: \(self.label), qos: \(self.dispatchQueue.qos), concurrencyMode: \(self.concurrencyMode))"
    }
}
