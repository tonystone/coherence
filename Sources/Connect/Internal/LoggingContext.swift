///
///  LoggingContext.swift
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
///  Created by Tony Stone on 2/5/17.
///
import CoreData

internal class LoggingContext: BackgroundContext {

    ///
    /// Container access to the writeAheadLog.
    ///
    internal var logger: WriteAheadLog? = nil

    public override func save() throws {

        if let logger = logger {

            ///
            /// Obtain permanent IDs for all inserted objects
            ///
            try self.obtainPermanentIDs(for: [NSManagedObject](self.insertedObjects))

            ///
            /// Log the changes from the context in a transaction
            ///
            let transactionID = try logger.logTransactionForContextChanges(self)

            ///
            /// Save the main context
            ///
            do {
                try super.save()
            } catch {
                try logger.removeTransaction(transactionID)

                throw error
            }
        } else {
            try super.save()
        }
    }
}
