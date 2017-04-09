//: Playground - noun: a place where people can play

import UIKit
import CoreData

@testable import Coherence

let defaultBundleLocation = GenericConnect<ContextStrategy.Mixed>.defaultStoreLocation()

let config1 = Configuration(storeConfigurations: [StoreConfiguration(name: "persistent1"), StoreConfiguration(name: "persistent2"), StoreConfiguration(name: "transient", type: NSInMemoryStoreType)])

let resolved1 = config1.resolved(defaultLocation: URL(fileURLWithPath: "/dir/path/HR.connect"))

resolved1.storeConfigurations


let config2 = Configuration(location: URL(fileURLWithPath: "/my/custom/directory"), storeConfigurations: [StoreConfiguration(name: "persistent")])

let resolved2 = config2.resolved(defaultLocation: URL(fileURLWithPath: "/dir/path"))

resolved2.storeConfigurations
