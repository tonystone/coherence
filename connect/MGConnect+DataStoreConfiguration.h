//
//  MGConnect+DataStoreConfiguration.h
//  MGConnect
//
//  Created by Tony Stone on 3/28/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGConnect.h"

/**
 DataStore Options
 
 Keys for the options dictionary used in openDataStore:managedObjectModel:persistentStoreType:options:
 
 These options can be passed to the resource manager on open of a datastore
 to set various static behaviours.
 */
extern NSString * const MGRemoveIncompatibleStoreOption;
extern NSString * const MGPersistentStoreTypeStoreKey;
extern NSString * const MGPersistentStoreGroupIDStoreKey;
extern NSString * const MGPersistentStoreInstanceIDStoreKey;
extern NSString * const MGPersistentStoreDataInitializerClassStoreKey;

/**
 
 MGRemoveIncompatibleStoreOption
 
    Check to see if the persistent stores are compatible, if not remove them and recreate them.
 
 MGPersistentStoreTypeStoreKey
         
    One of NSSQLiteStoreType, NSBinaryStoreType, NSInMemoryStoreType;
 
    All other tables not in one of the configurations list will be put into one
    store with the default storeType NSSQLiteStoreType.
 
 MGPersistentStoreGroupIDStoreKey
 MGPersistentStoreInstanceIDStoreKey
 
 
 */

@class NSManagedObjectModel;

@interface MGConnect (DataStoreConfiguration)

    /**
     You must register the object models you will use.  Register 
     them early and once registered you will have access to the 
     extended attributes that MGConnect exposes.

     */
    - (void) registerDataStore: (NSString *) dataStoreName managedObjectModel: (NSManagedObjectModel *) aModel;

    /**
     MGConnect can be configured to support partitioning
     of the data in the cache into configurations with different
     storeTypes for each configuration.  
     
     Parameters:
     
     dataStoreName
     
        A name you give the store. It must be unique between stores.
     
     options:
     
        If an NSDictionary keyed by NSManagedObjectModel configuration name and a value of the type of store
     
        An NSDictionary with either a list of DataStore options above or a list of NSManagedObjectModel configuration names 
        with the values as above.
     
        Any keys that do not match one of the options above are taken as a configuration name and it's expected to have an NSDictionary with the values
        above in it for that configuration.
     
        See DataStore options above
     
     */
    - (void) openDataStore: (NSString *) dataStoreName options: (NSDictionary *) options;

    /**
     Close the dataStore named by dataStoreName
     
     Parameters:
     
     dataStoreName
     
        A name you give the when you opened it.
     
     */
    - (void) closeDataStore: (NSString *) dataStoreName;


    /**
        Get the main thread NSManagedObjectContext for the named dataStore.
     */
    - (NSManagedObjectContext *) mainThreadManagedObjectContextForDataStore: (NSString *) dataStoreName;

    /**
     Get an instance of an edit NSManagedObjectContext for the named dataStore.
     */
    - (NSManagedObjectContext *) editManagedObjectContextForDataStore: (NSString *) dataStoreName;


@end

