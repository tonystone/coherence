///
///  StoreConfiguration+Extensions.swift
///  Pods
///
///  Created by Tony Stone on 4/23/17.
///
///
import Swift
import CoreData

internal extension StoreConfiguration {

    ///
    /// Returns a new Configuration resolved against the defaultBundleLocation and bundleName.
    ///
    internal func resolveURL(defaultStorePrefix: String, storeLocation: URL) -> URL? {

        ///
        /// If this is an InMemory type store, assign nil since it should not have a file
        /// associated with it. otherwise resolve the path
        ///
        if self.type == NSInMemoryStoreType {
           return nil
        }

        ///
        /// If the user did not supply a URL, we build a default URL based on the parameter defaults
        /// and what is contained in the configuration.
        ///
        if let fileName = self.fileName {
                return storeLocation.appendingPathComponent(fileName)
        }

        return StoreConfiguration.storeURL(prefix: defaultStorePrefix, configuration: self.name, type: self.type, location: storeLocation)
    }

    internal /// @testable
    static func storeURL(prefix: String, configuration: String? = nil, type: String, location: URL) -> URL {

        var storeName = prefix

        if let configurationName = configuration {
            storeName.append(".\(configurationName.lowercased())")
        }
        storeName.append(".\(type.lowercased())")

        return location.appendingPathComponent("\(storeName)")
    }
}
