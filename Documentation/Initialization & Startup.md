# Coherence
## Initialization & Startup

During initialization and startup of **Coherence** you can rely on its default behavior, or you can take complete control over these aspects.

Both `GenericConnect` and `GenericPersistentContainer` implement the `PersistentStack` protocol.  This means that the initialization and startup sequence is the same except that `GenericConnect` has one additional requirement which is to `start` the instance.  Other than that, they are completely interchangeable as a `PersistentStack`.

Persistent stores can be attached and detached in steps to facilitate various requirements and use cases.  For instance, you may want to bring a global store online that stores your user tables so you can determine the logged in user.  The user information can be used to decide the proper stores to attach for that user.   This can be accomplished through the methods `attachPersistentStore(for:)` and `detach(persistentStore:)`.

> Note: Both `attachPersistentStore(for:)` and `detach(persistentStore:)` have plural equivalents (`attachPersistentStores(for:)` and `detach(persistentStores:)`) that allow you to attach and detach multiple stores at a time.  In the case of `attach`, you attach multiple stores at the same location (`url`).  Both versions can be intermixed if required.

Stores can be attached at any time after you create the `Connect` or `PersistentStack` instance.  The "attach" methods all take a `StoreConfiguration` which can be used to specify various aspects of the stores as well as an `url` that specifies the location to store the file.

Below we've created startup examples for various use cases including the case described above.

### No Configuration Required

In this scenario, the developer wants a no hassle, simple configuration, so all that is needed are the default values that **Coherence**.  This scenario is as simple as starting the instance after it is instantiated.

```swift
let connect: Connect = GenericConnect<ContextStrategy.Mixed>(name: "MyModelName")

try connect.start()
```

### Custom Configuration Required

In this scenario, the developer has a custom configuration setup for the persistent stores that he wants to maintain.
```swift
let connect: Connect = GenericConnect<ContextStrategy.Mixed>(name: "MyModelName")

try connect.attachPersistentStores(for: [StoreConfiguration(name: "TransientData",  type: NSInMemoryStoreType),
                                         StoreConfiguration(name: "PersistentData", type: NSSQLiteStoreType)])
try connect.start()
```
There are two configurations defined in the users model `TransientData` and `PersistentData` which will be stored in different types of PersistentStores.  In the case of `TransientData`, it will be stored in a `NSInMemoryStoreType` since it is not required to persist between application starts.  `PersistentData` on the other hand, will be stored persistently in a `NSSQLiteStoreType` store at the `defaultStoreLocation`.

### User per configuration

In this scenario, the developer wants a Configuration/PersistentStore per user that logs into the application.
```swift
let connect: Connect = GenericConnect<ContextStrategy.Mixed>(name: "MyModelName")

let userName = loggedInUserName() /* Determine user that is logged */

try connect.attachPersistentStores(at:  URL(fileURLWithPath: "/persistentStores/location/\(userName)"),
                                   for: [StoreConfiguration(name: "TransientData",  type: NSInMemoryStoreType),
                                         StoreConfiguration(name: "PersistentData", type: NSSQLiteStoreType)])

try connect.start()
```
The first step would be to figure out what user is logged in.  Once that information is obtained, `attachPersistentStores(at:for:) can be called with an `url` that points to the location of the stores for the logged in user.


### Global Store, User per configuration

In this scenario, the developer starts a global PersistentStore(s) before starting to connect with a custom Configuration/StoreConfigurations per user that logs into the application.
```swift
let connect: Connect = GenericConnect<ContextStrategy.Mixed>(name: "MyModelName")

try connect.attachPersistentStore(at: URL(fileURLWithPath: "/persistentStores/location"), for: StoreConfiguration(name: "GlobalData", type: NSSQLiteStoreType))

let userName = loggedInUserName() /* Determine user that is logged */

try connect.attachPersistentStores(at:  URL(fileURLWithPath: "/persistentStores/location/\(userName)"),
                                   for: [StoreConfiguration(name: "TransientData",  type: NSInMemoryStoreType),
                                         StoreConfiguration(name: "PersistentData", type: NSSQLiteStoreType)])

try connect.start()
```
This can be achieved by first opening a persistent user database to locate information about the logged in user.  Once determined, PersistentStores in a user specific directory can be opened.  This scenario is very similar to above with the exception that an `url` is specified for the global store in addition to the `url` for the user specific stores.
