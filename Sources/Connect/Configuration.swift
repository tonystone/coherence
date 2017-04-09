///
///  ConnectConfiguration.swift
///  Pods
///
///  Created by Tony Stone on 4/6/17.
///
///
import Swift
import CoreData

///
/// A configuration object used to configure a Connect instance and PersistentStores.
///
public struct Configuration {

    ///
    /// Location for Connect's files.
    ///
    /// By default Connect creates a bundle to store various files in including the PersistentStores 
    /// associated with this instance, setting this value will override this behavior.
    ///
    public var location: URL

    ///
    /// A StoreConfiguration object for each store that will be created.
    ///
    public var storeConfigurations: [StoreConfiguration]

    ///
    /// Required init.
    ///
    public init(location: URL = Default.location, storeConfigurations: [StoreConfiguration] = Default.storeConfigurations) {
        self.location            = location
        self.storeConfigurations = storeConfigurations
    }
}

internal extension Configuration {

    struct Default {

        static let location: URL = URL(fileURLWithPath: "/dev/null")

        static let storeConfigurations: [StoreConfiguration] = []

        static let storeName: String = "default"
    }
}

extension Configuration: CustomStringConvertible {

    public var description: String {
        return "<\(String(describing: type(of: self)))> (location: \(self.location == Default.location ? "default" : self.location.path), storeConfigurations: \(self.storeConfigurations))"
    }
}

internal extension Configuration {

    ///
    /// Returns a new Configuration resolved against the defaultBundleLocation and bundleName.
    ///
    internal func resolved(defaultLocation: URL, defaultStoreConfiguration: StoreConfiguration = StoreConfiguration()) -> Configuration {

        let resolvedLocation = self.location == Default.location ? defaultLocation : self.location
        var storeConfigurations: [StoreConfiguration] = []

        if self.storeConfigurations.count == 0 {
            storeConfigurations.append(defaultStoreConfiguration.resolved(defaultLocation: resolvedLocation))
        } else {
            for storeConfiguration in self.storeConfigurations {
                storeConfigurations.append(storeConfiguration.resolved(defaultLocation: resolvedLocation))
            }
        }
        return Configuration(location: resolvedLocation, storeConfigurations: storeConfigurations)
    }
}

internal extension StoreConfiguration {

    ///
    /// Returns a new Configuration resolved against the defaultBundleLocation and bundleName.
    ///
    internal func resolved(defaultLocation: URL) -> StoreConfiguration {
        var storeConfiguration = self

        let storeName = self.name ?? Configuration.Default.storeName

        ///
        /// If this is an InMemory type store, assign nil since it should not have a file
        /// associated with it. otherwise resolve the path
        ///
        if self.type == NSInMemoryStoreType {
            storeConfiguration.url = nil
        } else {
            storeConfiguration.url = storeConfiguration.url ?? defaultLocation.appendingPathComponent("\(storeName.lowercased()).\(storeConfiguration.type.lowercased())")
        }

        return storeConfiguration
    }
}
