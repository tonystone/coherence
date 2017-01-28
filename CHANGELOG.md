# Change Log
All significant changes to this project will be documented in this file.

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

