///
///  GenericActionContainer.swift
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

class GenericActionContainer<ActionType: GenericAction>: ActionContainer {

    private let genericAction: ActionType

    internal init(action: ActionType, notificationService: NotificationService, completionBlock: ((_ actionProxy: ActionProxy) -> Void)?) {
        self.genericAction = action

        super.init(action: action, notificationService: notificationService, completionBlock: completionBlock)

        logTrace(Log.tag, level: 4) { "Proxy \(self) created for action \(self.action)." }
    }

    internal override func execute() throws {
        try self.genericAction.execute()
    }

    override func cancel() {
        self.genericAction.cancel()

        super.cancel()
    }
}
