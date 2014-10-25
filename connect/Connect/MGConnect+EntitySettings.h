//
//  MGConnect+EntitySettings.h
//  MGConnect
//
//  Created by Tony Stone on 4/3/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGConnect.h"
#import <CoreData/CoreData.h>

@class MGEntityActionDefinition;
@protocol MGEntityActionNotificationDelegate;

@protocol MGEntitySettings <NSObject>

@required
    /**
     Sets the amount of time that before the resource is updated again from the master source
     
     Default is 60 seconds
     */
    @property (nonatomic, assign) NSUInteger stalenessInterval;

    /**
     This option turns the logging feature  on or off
     
     */
    @property (nonatomic, assign) BOOL logTransactions;

    /**
     This is the name of the class to use for the ResourceWebLink class.
     
     It defaults to <entity name>EntityActionDefinition
     */
    @property (nonatomic, strong) MGEntityActionDefinition * entityActionDefinition;

    /**
     Set the delegate to be called back for this entity when an action occurs.
     
     Actions are List, Read, Insert, Update, Delete and Custom.
     
     See MGEntityActionNotificationDelegate for information on callback methods
     */
    @property (nonatomic, strong) NSObject <MGEntityActionNotificationDelegate> * actionNotificationDelegate;

@end

@interface NSManagedObjectModel (MGEntitySettings) <MGEntitySettings>
    // Note:  All protocol MGEntitySettings properties are implemented
@end

@interface NSEntityDescription (MGEntitySettings) <MGEntitySettings>
    // Note:  All protocol MGEntitySettings properties are implemented
@end

