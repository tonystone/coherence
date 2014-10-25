//
//  MGConnectManagedObjectActionMessage.h
//  Connect
//
//  Created by Tony Stone on 5/28/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGConnectActionMessage.h"

@interface MGConnectManagedObjectActionMessage : MGConnectActionMessage

- (id) initWithManagedObject: (NSManagedObject *) aManagedObject;

@end
