///
///  StoreConfiguration.swift
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
///  Created by Tony Stone on 3/17/17.
///
import Foundation
import Swift
import CoreData

extension StoreConfiguration {

    public struct Default {

        public static let fileName: String? = nil

        public static let name: String? = nil

        public static let type: String = NSSQLiteStoreType

        public static let overwriteIncompatibleStore: Bool = false

        public static let options:[String: Any] = [NSInferMappingModelAutomaticallyOption: true, NSMigratePersistentStoresAutomaticallyOption: true]
    }
}

///
/// A description object used to create and/or load a persistent store.
///
public struct StoreConfiguration {

    public init(fileName: String?                = Default.fileName,
                name: String?                    = Default.name,
                type: String                     = Default.type,
                overwriteIncompatibleStore: Bool = Default.overwriteIncompatibleStore,
                options: [String: Any]           = Default.options) {

        self.fileName                   = fileName
        self.name                       = name
        self.type                       = type
        self.overwriteIncompatibleStore = overwriteIncompatibleStore
        self.options                    = options
    }

    ///
    /// The name of the file that will be written to disk.
    ///
    public var fileName: String?

    ///
    /// The name of the configuration used by this store.
    ///
    public var name: String?

    ///
    /// The type of store to create when loading.
    ///
    public var type: String

    ///
    /// A flag that when set to true – will check if the persistent store and the model are incompatible.
    /// If so, the underlying persistent store will be removed and replaced.
    ///
    public var overwriteIncompatibleStore: Bool

    ///
    /// A dictionary representation of the options set on the persistent store.
    ///
    public var options: [String: Any]
}

extension StoreConfiguration: CustomStringConvertible {

    public var description: String {
        var string = "<\(String(describing: type(of: self)))> ("

        if let fileName = self.fileName {
            string.append("fileName: '\(fileName)', ")
        }

        if let name = self.name {
            string.append("name: '\(name)', ")
        }
        string.append("type: \(self.type))")

        return string
    }
}

extension StoreConfiguration: Equatable {}

public func == (lhs: StoreConfiguration, rhs: StoreConfiguration) -> Bool {
    return lhs.fileName == rhs.fileName &&
           lhs.name == rhs.name &&
           lhs.type == rhs.type &&
           lhs.overwriteIncompatibleStore == rhs.overwriteIncompatibleStore &&
           NSDictionary(dictionary: lhs.options).isEqual(to: rhs.options)
}
