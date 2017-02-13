///
///  MockListAction.swift
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
///  Created by Tony Stone on 1/22/17.
///
import UIKit
import CoreData
import TraceLog
import Coherence

class MockListAction: EntityAction {

    typealias ManagedObjectType = ConnectEntity1

    private enum Errors: Error {
        case testError(String)
    }

    private var testValues: [ManagedObjectType]

    public init(testValues: [ManagedObjectType]) {
        self.testValues = testValues
    }

    public func execute(context: ActionContext) throws {

        logInfo { "Executing..." }
        guard let entity = NSEntityDescription.entity(forEntityName: "ConnectEntity1", in: context) else {
            throw Errors.testError("Failed to get entity for ConnectEntity1.")
        }

        ///
        /// Merge the values set in the init into the DB
        ///
        try context.performAndWait {
            try context.merge(objects: self.testValues, for: entity)
        }
    }

    ///
    /// All Actions must be cancelable
    ///
    public func cancel() {}
}
