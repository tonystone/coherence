# Change Log
All significant changes to this project will be documented in this file.

## [3.0.0-beta.3](https://github.com/tonystone/coherence/releases/tag/3.0.0-beta.3) 

#### Breaking Updates 
- Changed init sequence allowing for non-throwing init.
- Removed `GenericCoreDataStack` default persistent option `NSMigratePersistentStoresAutomaticallyOption`.
- Removed `GenericCoreDataStack` default persistent option `NSInferMappingModelAutomaticallyOptionChanged`.
- `GenericCoreDataStack` now has a generic parameter for `ViewContextType` which must be specified.
- Changed `GenericCoreDataStack` & `CoreDataStack` `viewContext` to use the `ViewContextType` removing the read only context.

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

