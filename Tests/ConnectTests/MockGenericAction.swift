//
//  TestGenericAction.swift
//  Coherence
//
//  Created by Tony Stone on 1/22/17.
//  Copyright © 2017 Tony Stone. All rights reserved.
//

import UIKit
import TraceLog
import Coherence

class MockGenericAction: GenericAction {

    public func execute() -> (status: Int, headers: [String: String], objects: [Any], error: Error?) {

        logInfo { "\(String(describing: self)).\(#function) executed..." }

        return (200, [:], [], nil)
    }

    ///
    /// All Actions must be cancelable
    ///
    public func cancel() {}
}
