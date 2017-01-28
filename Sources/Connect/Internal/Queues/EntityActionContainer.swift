///
///  EntityActionContainer.swift
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
///  Created by Tony Stone on 1/22/17.
///
import TraceLog
import CoreData

class EntityActionContainer<ActionType: EntityAction>: ActionContainer {

    private let action: ActionType
    private let context: NSManagedObjectContext

    internal init(action: ActionType, context: NSManagedObjectContext, notificationService: ActionNotificationService, completionBlock: ((_ actionProxy: ActionProxy) -> Void)?) {
        self.action = action
        self.context = context

        super.init(notificationService: notificationService, completionBlock: completionBlock)

        logTrace(1) { "Proxy \(self) created for action \(self.action)." }
    }

    internal override func execute() -> ActionCompletionStatus {

        let (status, _, _, _) = self.action.execute(context: context)

        switch status {

        case 200:
            return .successful
        default:
            return .failed
        }
    }
}
