//
//  MGConnectManagedObjectContext+Private.h
//  Connect
//
//  Created by Tony Stone on 5/16/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGConnectManagedObjectContext.h"

@interface MGConnectManagedObjectContext (Internal)

- (id) initSynchronized: (BOOL) synchronized logged: (BOOL) logged connectManaged: (BOOL) connectManaged;

- (BOOL) logged;
- (BOOL) synchronized;
- (BOOL) connectManaged;

@end

