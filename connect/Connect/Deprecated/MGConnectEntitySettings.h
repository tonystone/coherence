//
//  MGConnect+EntitySettings.h
//  Connect
//
//  Created by Tony Stone on 5/18/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import <CoreData/CoreData.h>

@protocol MGConnectEntitySettings <NSObject>

    /**
     Sets the amount of time that before the resource is updated again from the master source
     
     Default is 60 seconds
     */
    @property (nonatomic, assign) NSUInteger stalenessInterval;

    /**
     This option turns the logging feature  on or off
     
     */
    @property (nonatomic, assign) BOOL logTransactions;

@end

/**
 NSManagedObjectModel implements the methods in the MGConnectEntitySettings protocol
 
 Any of the settings from this protocol, if set on the model, act as the default
 for all entities in the model.
 
 NOTE: These are global settings for any place this model is used.  Therefor, if
       you use the model for more than one NSPersistentStoreCoordinator, the settings
       we will in affect for all instances.
 */
@interface NSManagedObjectModel (MGConnectEntitySettings) <MGConnectEntitySettings>
    // Note:  All protocol MGConnectEntitySettings properties are implemented
@end

/**
 NSEntityDescription implements the methods in the MGConnectEntitySettings protocol
 
 Any of the settings from this protocol, if set on the entity, will be specific
 for that entity overriding what ever setting is set in the model.
 
 NOTE: These are global settings for any place this entity is used.  Therefor, if
 you use the model that this entity is contain in for more than one 
 NSPersistentStoreCoordinator, the settings we will in affect for all instances.
 */
@interface NSEntityDescription (MGConnectEntitySettings) <MGConnectEntitySettings>
    // Note:  All protocol MGConnectEntitySettings properties are implemented
@end
