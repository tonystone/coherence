//
//  MGConnect.h
//  MGConnect
//
//  Created by Tony Stone on 7/2/14.
//  Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/NSEntityDescription.h>
#import <CoreData/NSPersistentStoreCoordinator.h>
#import <Common/Version.h>

/** @name Public Version Constants
*
* @note This class implements the MGVersion category
*       so these constants are also available dynamically
*       threw the version interface.   Ony use the constants
*       below for pre-processor style #ifdef work if needed.
*
*       The [MGConnect versionInfo] interface is preferred.
*
*/
//@{
#define MGConnectVersion_MAJOR 1
#define MGConnectVersion_MINOR 0
#define MGConnectVersion_BUILD 1
//@}

/** @name Connect Persistent Store Types */
//@{

extern NSString * const MGSQLiteStoreType;
extern NSString * const MGInMemoryStoreType;

//@}

//
// Forward definitions
//
@protocol MGConnectActionMonitor;
@protocol MGConnectEntityActionDefinition;

/** @interface MGConnect

 Mobile Grid Connect is a runtime framework that manages local CoreData instances
 as a cache for remote resources.

 */
@interface MGConnect : NSObject <MGVersionInfo>

/** @name Initialization */
//@{

    /** @method
     Mobile Grid Connect can be initialized with special options if needed.  This is optional.

     This option can take an array of keys and options to control the
     way MGConnect functions.

     @param options an NSDictionary or keys and values, please see options below

     */
    + (void) initializeWithOptions: (NSDictionary *) options;

//@}

/** @name Version Info */
//@{

    /** @method
     Mobile Grid Connect allows for dynamically testing its runtime version.  This method returns a version structure you can use to test.

    */
    + (MGVersion) versionInfo;

//@}

/** @name Action Definition */
//@{

    /**
    If the automatic method is not used, you can set the action definitions manually
    using this method.

    Note: If one is already installed, this will remove it and install the new one.
    */
    + (void) registerActionDefinition: (id <MGConnectEntityActionDefinition>) actionDefinition forEntity: (NSEntityDescription *) entity persistentStoreCoordinator: (NSPersistentStoreCoordinator *) persistentStoreCoordinator;

//@}

/** @name Action Monitoring */
//@{
    /**
    Register a class that conformsTo MGConnectActionMonitor to monitor actions that
    MGConnect executes automatically as well as when you execute them manually.

    NOTES:

    A central concept to MGConnect are MGConnectActions.  Actions execute in the background
    for various tasks including syncrhonization of the local cache with the servers.

    You can monitor this activity by registering a class that conformsTo MGConnectActionMonitor.

    On iOS 6.x and later, the monitor class is unregistered automatically when the
    monitor is deallocated.
    */
    + (void) registerActionMonitor: (id <MGConnectActionMonitor>) monitor;

    /**
    Register a class that conformsTo MGConnectActionMonitor to monitor actions that
    are executed for for the entity passed in.

    See notes for registerActionMonitor for more details.
    */
    + (void) registerActionMonitor: (id <MGConnectActionMonitor>) monitor forEntity: (NSEntityDescription *) entity;

    //@}

@end


/** @name Initialization options */
//@{

    /**
     Sets the limit of Synchronized MGConnectManagedObjectContexts allocated
     per persistentStoreCoordinator on the main thread.

     Value Type: NSNumber (initialize with initWithInteger:)

     Default: @1

     */
    extern NSString * const MGConnectMainThreadManagedObjectContextLimitOption;

    /**
     By default MGConnect will take over CoreData and return
     it's own classes.  This option allows you to control that.

     NOTE: For this option to take affect, you must initialize MGConnect
           with this option BEFORE any CoreData class is referenced or called
           in your code, otherwise, this has no affect.

     Set this option to NO to turn this feature off.

     Value Type: NSNumber (initialize with initWithBool:)

     Default: @YES

     */
    extern NSString * const MGConnectTakeOverCoreDataOption;

//@}


