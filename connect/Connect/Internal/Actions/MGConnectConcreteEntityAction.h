//
//  MGConnectConcreteEntityAction.h
//  Connect
//
//  Created by Tony Stone on 5/27/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGConnectEntityAction.h"

@class MGManagedEntity;
@class MGWebServiceOperation;

@interface MGConnectConcreteEntityAction : MGConnectEntityAction {
@protected
    MGWebServiceOperation * webServiceOperation;
}

+ (MGConnectEntityAction *) entityAction: (NSString *) actionName managedEntity: (MGManagedEntity *) managedEntity;

- (id) initWithName:(NSString *)name entity: (NSEntityDescription *) anEntity webServiceOperation: (MGWebServiceOperation *) aWebServiceOperation;

@end
