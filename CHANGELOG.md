# Change Log
All significant changes to this project will be documented in this file.

## [5.0.0](https://github.com/tonystone/coherence/releases/tag/5.0.0)

#### Fixed
- Fixed issue where the main context was not being updated when a background context was saved.

#### Removed
- Removed Write Ahead Logging since it was not exposed and enhancing the performance.

## [4.2.0](https://github.com/tonystone/coherence/releases/tag/4.2.0)

#### Added
- Added the ability to ignoreAttributes during a `ActionContext.merge`.
- Added the ability to enable/diable logging when initializing an instance of `GenericConnect`.  Default is now logging is disabled.
- Updated meta data model to use NSSecureCoding to conform with Apple's new requirements.

## [4.1.0](https://github.com/tonystone/coherence/releases/tag/4.1.0)

#### Added
- Added the ability to supply a condition for merge that will be evaluated for each object being merged to determine if it should take action.
- Connect will now ignore Abstract entities when determining if they can be managed.
- Connect will now use the parent entity to determine if an entity can be managed.

## [4.0.0](https://github.com/tonystone/coherence/releases/tag/4.0.0)

#### Updates
- Updated Swift Version to 4.2.
- Changed TraceLog dependency requirement to ">= 3", "<= 5"
- Moved to minimum iOS deployment target of 9.0
- Moved to minimum macOS deployment target of 10.13

## [4.0.0-beta.1](https://github.com/tonystone/coherence/releases/tag/4.0.0-beta.1)

#### Breaking Updates
- Renamed `PersistentStack` to `PersistentContainer`.
- Change `PersistentContainer` to @objc so you can now pass references to Objective-C.
- Changed `Connect` to @objc so you can now pass references to Objective-C.
- Split `Connect` protocol into `Connect` and `ActionManager` protocols.
- Changed `StoreConfiguration` to be a class instead of a struct to support Objective-C.
- Removed `ObjcPersistentContainer` as it's no longer needed with the new changes to the protocols.

#### Updated
- Changed `GenericConnect` to subclass `NSObject`.

## [3.2.0](https://github.com/tonystone/coherence/releases/tag/3.2.0)

#### Added
- Added the ability to supply an  `AsyncErrorHandlerBlock`  to `GenericConnect` init methods.

## [3.1.0](https://github.com/tonystone/coherence/releases/tag/3.1.0)

This is a minor release to update the Swift language to 4.1 and Xcode to 9.3.

## [3.0.0](https://github.com/tonystone/coherence/releases/tag/3.0.0)

Please see the previous 3.0.0-beta.x releases for a complete list of features and changes.

#### Updated
- Changed defaultStoreLocation from applicationSupport directory to ApplicationSupport directory + "Coherence"

#### Removed
- Removed broken Swift PM support (will re-release in next release)

## [3.0.0-beta.5](https://github.com/tonystone/coherence/releases/tag/3.0.0-beta.5)

#### Added
- Added support for Xcode 9 and Swift 4 compiler.
- Added `attachPersistentStore` and `attachPersistentStores` to `PersistentStack` and classes that implement it, `GenericConnect` and `GenericPersistentContainer`.
- Added `InMemorySequence` for log entry sequence numbering.
- Added `FileBackedSequence` as an alternative for log entry sequence (persistent).
- Added `==` to `StoreConfiguration` for equality comparison.

#### Updated
- Renamed `Configuration` to `StoreConfiguration`.
- Moved `start` and `stop` blocks to execute on the global queue instead of the internal queue.
- Changed performAndWait to non-escaping on Swift 3.2 and above.

#### Removed
- Removed `loadPersistentStores` from `GenericPersistentContainer` (use `attachPersistentStore(s)` instead).
- Removed `url` from `Confuration` instead realying on `url` passed to the new `attachPersistentStore(s)` methods.

## [3.0.0-beta.4](https://github.com/tonystone/coherence/releases/tag/3.0.0-beta.4)

#### Added
- Added `ContextStrategyType` allowing different ManagedObjectContext layout strategies to be used for both `Connect` and `GenericPersistentContainer`.
- Added `BackgroundContext` which is the base type returned from `ContextStrategy` `newBackgroundContext`.
- Added `Configuration` class to allow configuration of Connect instances.
- Added `stop` state management to `Connect`.
- Added `unloadPersistentStores` state management to `GenericPersistentContainer`.

#### Breaking Updates
- Changed `Connect` to generic class to support `ContextStrategyType`.
- Changed `GenericPersistentContainer` generic parameters to support `ContextStrategyType`.
- Rmeoved `ViewContextType` from `GenericPersistentContainer` generic parameters.
- Updated to require *Swift 3.1*.
- Updated to require *Xcode 8.3*
- Removed `Configuration` subspec from project.  Note this will be moved into its own project.

## [3.0.0-beta.3](https://github.com/tonystone/coherence/releases/tag/3.0.0-beta.3)

#### Added
- Added `Notification.ActionDidStartExecuting` notification for clients to listen for action start notifications.
- Added `Notification.ActionDidFinishExecuting` notification for clients to listen for action finished notifications.
- Added `Notification.Key.ActionProxy` key used by notifications.
- Added `Connect` `suspended` functionality to control state.

#### Breaking Updates
- Changed init sequence allowing for non-throwing init.
- Removed `GenericCoreDataStack` default persistent option `NSMigratePersistentStoresAutomaticallyOption`.
- Removed `GenericCoreDataStack` default persistent option `NSInferMappingModelAutomaticallyOptionChanged`.
- `GenericCoreDataStack` now has a generic parameter for `ViewContextType` which must be specified.
- Changed `GenericCoreDataStack` & `CoreDataStack` `viewContext` to use the `ViewContextType` removing the read only context.
- Changed default merge policy for `ActionContext` to `NSMergeByPropertyObjectTrumpMergePolicy`
- Changed `NSEntityDescription.uniquenessAttributes` to be non-optional.
- Removed `Connect` `online` replacing them with `suspended`.
- Renamed `GenericCoreDataStack` to `GenericPersistentContainer`.
- Renamed `ObjcCoreDataStack` to `ObjcPersistentContainer`.
- Dropped `CoreDataStack` protocol.
- Changed init option `StoreConfiguration` into a formal struct to make it simpler to use.

#### Fixed
- `ActionProxy` cancel timing.  `ActionProxy` now correctly cancels actions in various states and reports back the `completionStatus` as `canceled`.

#### Removed
- Removed direct support for complex migration (with `NSMigrationManager`) in `GenericCoreDataStack`, for complex migrations that require a migration manager, migrate externally before loading.
- Removed direct support for complex migration (with `NSMigrationManager`) in `ObjcCoreDataStack`, for complex migrations that require a migration manager, migrate externally before loading.
- Removed direct support for complex migration (with `NSMigrationManager`) in `Connect`, for complex migrations that require a migration manager, migrate externally before starting.

## [3.0.0-beta.2](https://github.com/tonystone/coherence/releases/tag/3.0.0-beta.2)

#### Added
- Added `ActionContext` which captures statistics about context usage.
- Added `ActionContext` merge routine for merging changing from remote connections.
- `EntityAction` execute now passed an ActionContext rather than an `NSManagedObjectContext`.

#### Breaking Updates
- Moved statistics in `ActionProxy` to it's own protocol.
- Converted `Action` protocol `execute` func to throw instead of returning a type.
- Changed `GenericCoreDataStack` & `CoreDataStack` `viewContext` to be read only, it will now throw an error if you save changes to it.

## [3.0.0-beta.1](https://github.com/tonystone/coherence/releases/tag/3.0.0-beta.1)

#### Added
- Added Connect framework with base features.
- New init to GenericCoreDataStack which accepts a URL for the location of the persistent stores and an optional prefix for the file.
- Added CoreDataStack protocol.

#### Breaking Updates
- Changed `GenericCoreDataStack` & `CoreDataStack` persistent store file extension to lower case.
- Changed `GenericCoreDataStack` & `CoreDataStack` persistent store file configuration name to lower.
- Changed name of `CoreDataStack` to `ObjcCoreDataStack`.
- Renamed `func editContext()` to `func newBackgroundContext()`.
- Renamed `func mainContext()` to `var viewContext()`.
- Changed async error handler error type from `NSError` to `Error`.
- Changed context model to be a hybrid model that connects the backgroundContexts directory to the persistent store and maintains the viewContext. Data from the viewContext is propagated to a root context that is persisted in a background thread.

## [2.0.3](https://github.com/tonystone/coherence/releases/tag/2.0.3)

#### Added
- Opening up persistentStoreCoordinator and managedObjectModel so they are accessible publicly.

#### Updated
- Fixing crash when TraceLog level is set to TRACE4 (it prints a message using an @escaping closure).

#### Removed
- Removal of Connect (pre-release) in the CocoaPod spec.

## [2.0.2](https://github.com/tonystone/coherence/releases/tag/2.0.2)

#### Changes
- Reorganized internally to contain Connect (pre-release).

## [2.0.1](https://github.com/tonystone/coherence/releases/tag/2.0.1)

- First release to CocoaPods master repo.

#### Changes
- None

## [2.0.0](https://github.com/tonystone/coherence/releases/tag/2.0.0)

#### Added
- Swift 3 support.
- Swift Package Manager Support.
- This CHANGELOG.md file.

#### Updated
- Changed from Swift 2.0 to Swift 3.
- Changed from CocoaPods 0.39.0 to 1.1.0.
- Change CoreDataStack init methods to throw instead of be failable.
- Changed default Info.plist key to CCConfiguration.
- Changed CCOverwriteIncompatibleStore to overwriteIncompatibleStore
- Changed to TraceLog 2.0.

#### Removed
- Removed PersistentStoreCoordinator until the remainder of the implementation is complete.
- Removed WriteAhead log (for the same reason as above)

