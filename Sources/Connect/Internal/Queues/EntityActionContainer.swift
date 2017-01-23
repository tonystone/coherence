//
//  EntityActionContainer.swift
//  Pods
//
//  Created by Tony Stone on 1/22/17.
//
//

import UIKit
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
