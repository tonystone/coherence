//
//  MGActionNotificationService.h
//  MGConnect
//
//  Created by Tony Stone on 4/1/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MGEntityAction;
@class NSManagedObjectModel;
@class NSEntityDescription;

@protocol MGEntityActionNotificationDelegate;

@interface MGActionNotificationService : NSObject

/**
 Register an MGEntityAction object for notification
 
 NOTE: this must be done before the object starts executing.
 */
+ (void) registerActionForNotification: (MGEntityAction *) anAction;

@end
