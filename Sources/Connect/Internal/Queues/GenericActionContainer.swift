//
//  GenericActionContainer.swift
//  Pods
//
//  Created by Tony Stone on 1/22/17.
//
//

import UIKit
import TraceLog

class GenericActionContainer<ActionType: GenericAction>: ActionContainer {

    private let action: ActionType

    internal init(action: ActionType, notificationService: ActionNotificationService, completionBlock: ((_ actionProxy: ActionProxy) -> Void)?) {
        self.action = action

        super.init(notificationService: notificationService, completionBlock: completionBlock)

        logTrace(1) { "Proxy \(self) created for action \(self.action)." }
    }

    internal override func execute() -> ActionCompletionStatus {
    
        let (status, _, _, _) = self.action.execute()

        switch status {

        case 200:
            return .successful
        default:
            return .failed
        }
    }
}
