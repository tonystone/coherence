//
//  ConnectContext.swift
//  Pods
//
//  Created by Tony Stone on 1/29/17.
//
//

import UIKit
import CoreData

internal class ConnectContext: NSManagedObjectContext {

    internal var logger: WriteAheadLog? = nil

    override func save() throws {

        if let logger = logger {
            //
            // Obtain permanent IDs for all inserted objects
            //
            try self.obtainPermanentIDs(for: [NSManagedObject](self.insertedObjects))

            //
            // Log the changes from the context in a transaction
            //
            let transactionID = try logger.logTransactionForContextChanges(self)

            //
            // Save the main context
            //
            do {
                try super.save()

            } catch {
                logger.removeTransaction(transactionID)

                throw error
            }
        } else {
            try super.save()
        }
    }
}
