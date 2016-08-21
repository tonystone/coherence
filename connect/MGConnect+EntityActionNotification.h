//
//  MGConnect+EntityActionNotification.h
//  MGConnect
//
//  Created by Tony Stone on 4/7/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGConnect+EntityAction.h"


@protocol MGEntityActionNotificationDelegate <NSObject>

@required
- (void)   actionStarted: (NSObject <MGEntityAction> *) anAction;

@optional
- (void)  actionFinished: (NSObject <MGEntityAction> *) anAction;
- (void) actionCancelled: (NSObject <MGEntityAction> *) anAction;

@end

