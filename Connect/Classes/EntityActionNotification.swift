//
// Created by Tony Stone on 8/21/16.
//

import Foundation

public protocol EntityActionNotificationDelegate  {

    func actionStarted(action : EntityAction)
    func actionFinished(action : EntityAction)
    func actionCancelled(action : EntityAction)
}