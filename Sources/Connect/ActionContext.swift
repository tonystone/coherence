///
///  ActionContext.swift
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
///  Created by Tony Stone on 1/29/17.
///
import CoreData

public class ActionContext: NSManagedObjectContext {

    ///
    /// The statistics for this Context
    ///
    internal let statistics = Statistics()

    ///
    /// - Note: We are using the core data dispatch queue to
    ///         synchronize access to `self.blockStartTime`.
    ///         
    ///         Make sure you only access this in a context
    ///         perform or performAndWait block.
    ///
    internal var blockStartTime: Date? = nil

    ///
    /// Container access to the writeAheadLog.
    ///
    internal var logger: WriteAheadLog? = nil

    public override func fetch(_ request: NSFetchRequest<NSFetchRequestResult>) throws -> [Any] {
        let start = Date()
        defer {
            self.statistics.fetchTime = self.statistics.fetchTime + Date().timeIntervalSince(start)
        }
        let results = try super.fetch(request)

        self.statistics.fetches = self.statistics.fetches + results.count

        return results
    }

    public override func save() throws {

        let inserts = self.insertedObjects.count
        let updates = self.updatedObjects.count
        let deletes = self.deletedObjects.count

        let start = Date()

        try super.save()

        self.statistics.saveTime = self.statistics.saveTime + Date().timeIntervalSince(start)

        self.statistics.inserts = self.statistics.inserts + inserts
        self.statistics.updates = self.statistics.updates + updates
        self.statistics.deletes = self.statistics.deletes + deletes
    }

    ///
    /// synchronously performs the block on the context's queue with a throwing block.  May safely be called reentrantly.
    ///
    public override func performAndWait(_ block: @escaping () -> Void) {

        super.performAndWait { () -> Void in
            var root: Bool = false

            ///
            /// For recursive calls we need to determine whether
            /// this is the root call of the recursion.  Root
            /// calls set the initial blockStartTime and calculate
            /// the context time of the context.
            ///
            /// If you set the blockStartTime then you must keep
            /// a local flag indicating that you did so that you
            /// can remove it when you are done and calculate the
            /// total context time of the block.
            ///
            /// - Note: we are using the core data dispatch queue to
            ///         synchronize access to `self.blockStartTime`.
            ///
            if self.blockStartTime == nil {
                self.blockStartTime = Date()
                root = true
            }

            block()

            if root, let start = self.blockStartTime {
                /// Calculate time
                self.statistics.contextBlockTime = self.statistics.contextBlockTime + Date().timeIntervalSince(start)
                self.blockStartTime = nil
            }
        }
    }

    public override func perform(_ block: @escaping () -> Void) {

        super.perform { () -> Void in
            var root:  Bool = false

            ///
            /// For recursive calls we need to determine whether
            /// this is the root call of the recursion.  Root
            /// calls set the initial blockStartTime and calculate
            /// the context time of the context.
            ///
            /// If you set the blockStartTime then you must keep
            /// a local flag indicating that you did so that you
            /// can remove it when you are done and calculate the
            /// total context time of the block.
            ///
            /// - Note: we are using the core data dispatch queue to
            ///         synchronize access to `self.blockStartTime`.
            ///
            if self.blockStartTime == nil {
                self.blockStartTime = Date()
                root = true
            }

            block()

            if root, let start = self.blockStartTime {
                /// Calculate time
                self.statistics.contextBlockTime = self.statistics.contextBlockTime + Date().timeIntervalSince(start)
                self.blockStartTime = nil
            }
        }
    }
}

/// Note: Due to a bug in the current implementation of the compiler, inner classes in extensions must be defined in the same file as the primary class.

///
/// Extension to implement the Statistics implementation of ConnectContext.
///
internal extension ActionContext {

    internal class Statistics {

        public internal(set) var inserts: Int = 0       /// Running total number of inserts
        public internal(set) var updates: Int = 0       /// Running total number of updates
        public internal(set) var deletes: Int = 0       /// Running total number of deletes

        public internal(set) var fetches: Int = 0

        public internal(set) var contextBlockTime: TimeInterval = 0
        public internal(set) var fetchTime:   TimeInterval = 0
        public internal(set) var saveTime:    TimeInterval = 0

        public var otherTime: TimeInterval {
            return self.contextBlockTime - self.fetchTime - self.saveTime
        }
    }
}

extension ActionContext.Statistics: CustomStringConvertible {

    var description: String {
        return String(format: "{\r\tcontextBlockTime: %.4f {" +
            "\r\t\t{" +
            "\r\t\t saveTime: %.4f {\r\t\t\tinserts: %ld\r\t\t\tupdates: %ld\r\t\t\tdeletes: %ld\r\t\t\t}" +
            "\r\t\tfetchTime: %.4f {\r\t\t\tfetches: %ld\r\t\t\t}" +
            "\r\t\totherTime: %.4f" +
            "\r\t\t}" +
            "\r\t}", self.contextBlockTime, self.saveTime, self.inserts, self.updates, self.deletes, self.fetchTime, self.fetches, self.otherTime)
    }
}
