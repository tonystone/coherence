///
///  PersistentStoreDescription.swift
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
import Swift
import CoreData

///
/// A description object used to create and/or load a persistent store.
///
public struct StoreConfiguration {

    public init(url: URL                         = Default.url,
                name: String?                    = Default.name,
                type: String                     = Default.type,
                overwriteIncompatibleStore: Bool = Default.overwriteIncompatibleStore,
                options: [String: Any]           = Default.options) {

        self.url                        = url
        self.name                       = name
        self.type                       = type
        self.overwriteIncompatibleStore = overwriteIncompatibleStore
        self.options                    = options
    }

    ///
    /// The URL specifying the stores location.
    ///
    public var url: URL?

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

extension StoreConfiguration {

    public struct Default {

        public static let url: URL = URL(fileURLWithPath: "/dev/null")

        public static let name: String? = nil

        public static let type: String = NSSQLiteStoreType

        public static let overwriteIncompatibleStore: Bool = false

        public static let options:[String: Any] = [NSInferMappingModelAutomaticallyOption: true, NSMigratePersistentStoresAutomaticallyOption: true]
    }
}

extension StoreConfiguration: CustomStringConvertible {

    public var description: String {
        return "<\(String(describing: type(of: self)))> (type: \(self.type), url: \(self.url?.absoluteString ?? "nil"))"
    }
}
