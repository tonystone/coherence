//
//  MGEntityReadAction.h
//  MGConnect
//
//  Created by Tony Stone on 4/14/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGConnectConcreteEntityAction.h"

@interface MGReadEntityAction : MGConnectConcreteEntityAction

- (id) initWithName:(NSString *)name entity: (NSEntityDescription *) anEntity webServiceOperation: (MGWebServiceOperation *) aWebServiceOperation manaagedEntity: (MGManagedEntity *) aManagedEntity;

@end
