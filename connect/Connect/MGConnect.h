//
//  MGConnect.h
//  MGConnect
//
//  Created by Tony Stone on 3/26/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>       // Note, core data is included as a convienence.
#import "MGInitializationException.h"
#import "MGRuntimeException.h"
#import "MGError.h"

//
// Local Declarations of used classes
//
@class NSManagedObjectModel;
@class NSManagedObjectContext;

/**
 MGConnect
 
 Manages all resources from threads to web services
 
 */
@interface MGConnect : NSObject {
@package
    void * _ics;
}
    /**
     Opens the persistent store for the model given.
     
     options:
     
     See options for MGConnectOptions
     */
    + (void) initializeWithManagedObjectModel: (NSManagedObjectModel *) aModel;

    /**
     Gets the single instance of this class
     
     NOTE:  This is the only way you should access this class
     */
    + (MGConnect *) sharedManager;

    /**
     Gets the main context from the resource manager.
     
     This context should be used for read operations only.  Use it 
     for all fetches and NSFechtedResultsControllers. 
     
     It will be maintained automatically by resource Manager and be kept consistent.
     
     WARNING: You should only use this context on the main thread.  If you must work on
              a background thread, use the method editManagedObjectContext while on
              the thread.  See that method for more details
     */
    - (NSManagedObjectContext *) mainThreadManagedObjectContext;

    /**
     Gets a new NSManagedObjectContext that can be used for
     updating objects.  At save time, resource manager will 
     merge those changes back to the mainManagedObjectContext.
     
     NOTE: This method and the returned NSManagedObjectContext can be 
           used on a background thread as long as you get the context
           while on that thread.  It can also be used on the main
           thread if gotten while on the main thread.
     
     */
    - (NSManagedObjectContext *) editManagedObjectContext;

@end
