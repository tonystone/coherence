//
// Created by Tony Stone on 8/21/16.
//

import Foundation

public protocol EntityActionNotificationDelegate  {

    func actionStarted(_ action : EntityAction)
    func actionFinished(_ action : EntityAction)
    func actionCancelled(_ action : EntityAction)
}
