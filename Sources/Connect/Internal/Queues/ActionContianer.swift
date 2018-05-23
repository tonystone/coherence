///
///  ActionContainer.swift
///
///  Copyright 2017 Tony Stone
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

    private let notificationService: NotificationService
    private let completion: ((_ actionProxy: ActionProxy) -> Void)?

    public let action: Action
    
    public internal(set) var state: ActionState  {

        willSet {
            if newValue == .executing {

                self._statistics.start()

            } else if newValue == .finished {

                self._statistics.stop()
            }
        }
        didSet {
            /// Notify the service that this action state changed
            self.notificationService.actionProxy(self, didChangeState: state)
        }
    }
    public private(set) var completionStatus: ActionCompletionStatus
    public private(set) var error: Error?
    public var statistics: ActionStatistics {
        return _statistics
    }
    internal let _statistics: Statistics

    internal init(action: Action, notificationService: NotificationService, completionBlock: ((_ actionProxy: ActionProxy) -> Void)?) {
        self.action              = action
        self.notificationService = notificationService
        self.completionStatus    = .unknown
        self.state               = .created
        self.error               = nil
        self.completion          = completionBlock
        self._statistics         = ActionContainer.Statistics()

        super.init()
    }

    internal func execute() throws {}

    override func main() {

        logInfo(Log.tag) { "Proxy \(self) started on thread \(Thread.current) at priority \(Thread.current.threadPriority)." }

        self.state = .executing

        defer {
            self.state = .finished

            logInfo(Log.tag) { "Proxy \(self) \(self.completionStatus), execution statistics: \(self.statistics)" }

            self.completion?(self)
        }

        guard completionStatus != .canceled else {
            return
        }

        ///
        /// Execute the action
        ///
        do {
            try autoreleasepool {
                try self.execute()
            }
            ///
            /// If canceled, we must maintain the canceled state
            ///
            if completionStatus != .canceled {
                completionStatus = .successful
            }
        } catch {
            self.error = error

            ///
            /// If canceled, we must maintain the canceled state
            ///
            if completionStatus != .canceled {
                completionStatus = .failed
            }

            logError(Log.tag) { "Action \(self.action) threw error: \(error)." }
        }
    }

    override func cancel() {
        self.completionStatus = .canceled

        self.action.cancel()
    }
}

extension ActionContainer {

    public override var description: String {
        return "<\(type(of: self)): \(Unmanaged.passUnretained(self).toOpaque())>)"
    }
}
