//
//  MockEntityAction.swift
//  Coherence
//
//  Created by Tony Stone on 1/22/17.
//  Copyright © 2017 Tony Stone. All rights reserved.
//

import UIKit
import CoreData
import TraceLog
import Coherence

class MockListAction: EntityAction {

    typealias EntityType = Employee

    public func execute(context: NSManagedObjectContext) -> (status: Int, headers: [String : String], objects: [Any], error: Error?) {

        logInfo { "\(String(describing: self)).\(#function) executed..." }

        return (200, [:], [], nil)
    }

    ///
    /// All Actions must be cancelable
    ///
    public func cancel() {}
}
