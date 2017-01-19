//
// Created by Tony Stone on 8/21/16.
//

import Foundation
import CoreData

public protocol EntityActionNotificationDelegate  {

    func actionStarted  <T: NSManagedObject>(_ action: EntityAction<T>)
    func actionFinished <T: NSManagedObject>(_ action: EntityAction<T>)
    func actionCancelled<T: NSManagedObject>(_ action: EntityAction<T>)
}
