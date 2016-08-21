//
//  MGConnect+EntityAction.h
//  MGConnect
//
//  Created by Tony Stone on 3/28/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGConnect.h"
#import "MGConnect+Action.h"
#import <CoreData/CoreData.h>

/**
 Entity Actions
 
 You can list anyone or all of these in the
 supportedActions method to indicate what
 actions are supported for this entity.
 
 */
extern NSString * const MGEntityActionList;
extern NSString * const MGEntityActionRead;
extern NSString * const MGEntityActionInsert;
extern NSString * const MGEntityActionUpdate;
extern NSString * const MGEntityActionDelete;

@class NSEntityDescription;

/**
 The MGEntityAction protocol will allow you to monitor the
 action before, during, and after execution.  This version includes
 a property to identify the NSEntityDescription that this action is for.
 
 See MGAction for the remainder of the properties.
 */
@protocol MGEntityAction <MGAction>
@required
    @property (nonatomic, readonly) NSEntityDescription * entity;

@end

@class MGEntityAction;

@interface MGConnect (EntityAction)

/**
 Refresh local copies of an Entity's resources from the server
 
 The where: parameter allows you to refresh a subset of those resources
 
 Notes:
 This is a manual method and is not normally needed if using automated RM
 
 This method will throw an exception if you pass YES to waitUntilDone while on the main thread.
 */
- (void) refreshEntity: (NSEntityDescription *) anEntity where: (NSPredicate *) aPredicateOrNil completionBlock: (MGActionCompletionBlock) completionBlock waitUntilDone: (BOOL) waitUntilDone;

/**
 Refresh local copies of an Entity's resources for a particular parent from the server
 
 The where: parameter allows you to refresh a subset of those resources within the parent
 
 Notes:
 This is a manual method and is not normally needed if using automated RM
 
 This method will throw an exception if you pass YES to waitUntilDone while on the main thread.
 */
//- (void) refreshEntity: (NSEntityDescription *) anEntity where: (NSPredicate *) aPredicateOrNil forParent: (id) aParentResourceOrResourceReference completionBlock: (MGActionCompletionBlock) completionBlock waitUntilDone: (BOOL) waitUntilDone;

/**
 Refresh local copies of an Entity's resources from the server
 
 The where: parameter allows you to refresh a subset of those resources
 
 Notes:
 This is a manual method and is not normally needed if using automated RM
 
 This method will throw an exception if you pass YES to waitUntilDone while on the main thread.
 */
//- (void) refreshObject: (id) aResourceOrResourceReference forEntity: (NSEntityDescription *) anEntity completionBlock: (MGActionCompletionBlock) completionBlock waitUntilDone: (BOOL) waitUntilDone;

/**
 Insert an object on the server and refresh the local copy
 
 Notes:
 This is a manual method and is not normally needed if using automated RM
 
 This method will throw an exception if you pass YES to waitUntilDone while on the main thread.
 */
//- (void) createObject: (id) aResourceOrDictionary existingObjectID: (NSManagedObjectID *) anExistingObjectIDOrNil forEntity: (NSEntityDescription *) anEntity completionBlock: (MGActionCompletionBlock) completionBlock waitUntilDone: (BOOL) waitUntilDone;

/**
 Update an object on the server and refresh the local copy
 
 Notes:
 This is a manual method and is not normally needed if using automated RM
 
 This method will throw an exception if you pass YES to waitUntilDone while on the main thread.
 */
//- (void) updateObject: (id) aResourceOrDictionary updatedAttributeKeyNames: (NSArray *) updatedAttributeKeyNames forEntity: (NSEntityDescription *) anEntity completionBlock: (MGActionCompletionBlock) completionBlock waitUntilDone: (BOOL) waitUntilDone;

/**
 Delete an object on the server and refresh the local copy
 
 Notes:
 This is a manual method and is not normally needed if using automated RM
 
 This method will throw an exception if you pass YES to waitUntilDone while on the main thread.
 */
//- (void) deleteObject: (id) aResourceOrResourceReference forEntity: (NSEntityDescription *) anEntity completionBlock: (MGActionCompletionBlock) completionBlock waitUntilDone: (BOOL) waitUntilDone;


@end
