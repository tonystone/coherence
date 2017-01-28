///
///  ActionContainer.swift
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
///  Created by Tony Stone on 1/19/17.
///
import Foundation
import TraceLog
import CoreData

internal class ActionContainer: Operation, ActionProxy {

    private let notificationService: ActionNotificationService
    private let completion: ((_ actionProxy: ActionProxy) -> Void)?

    public internal(set) var state: ActionState  {
        didSet {
            /// Notify the service that this action state changed
            self.notificationService.action(self, actionState: state)
        }
    }
    public private(set) var completionStatus: ActionCompletionStatus
    public private(set) var error: Error?

    public private(set) var startTime:  Date?
    public private(set) var finishTime: Date?
    public private(set) var executionTime: TimeInterval?

    internal init(notificationService: ActionNotificationService, completionBlock: ((_ actionProxy: ActionProxy) -> Void)?) {
        self.notificationService = notificationService
        self.completionStatus    = .unknown
        self.state               = .created
        self.error               = nil
        self.completion          = completionBlock

        self.startTime           = nil
        self.finishTime          = nil
        self.executionTime       = nil

        super.init()
    }

    internal func execute() -> ActionCompletionStatus {
        return .successful
    }

    override func main() {
        let start = Date()
        self.startTime = start

        self.state = .executing

        logTrace(1) { "Proxy \(self) executing on thread \(Thread.current) at priority \(Thread.current.threadPriority)." }

        ///
        /// Execute the action
        ///
        self.completionStatus = self.execute()

        /// Note: setting the finishTime before
        /// setting the state to .finished is 
        /// intentional so that the finish time
        /// is available when the notification
        /// is sent.
        let finish = Date()
        self.finishTime = finish

        self.state = .finished

        let elapsedTime = finish.timeIntervalSince(start)
        self.executionTime = elapsedTime
        
        logTrace(1) { "Proxy \(self) finished, total run time \(elapsedTime)." }

        if let completionBlock = completion {
            completionBlock(self)
        }
    }

    override func cancel() {
        super.cancel()
        
        self.completionStatus = .canceled

        logTrace(1) { "Proxy \(self) canceled." }
    }
}

extension ActionContainer {

    public override var description: String {
        return "<\(type(of: self)): \(Unmanaged.passUnretained(self).toOpaque())>)"
    }

    public override var debugDescription: String {
        return self.description
    }
}
