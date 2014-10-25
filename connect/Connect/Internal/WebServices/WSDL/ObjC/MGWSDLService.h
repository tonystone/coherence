//
//  MGWSDLService.h
//  MGResourceManager
//
//  Created by Tony Stone on 4/10/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGWSDLComponent.h"

@class MGWSDLInterface;
@class MGWSDLEndpoint;

@interface MGWSDLService : MGWSDLComponent

- (MGWSDLInterface *) interface;
- (NSDictionary *) endpoints;

@end


@interface MGWSDLService (Initialization)

- (id) initWithName:(NSString *)name interface: (MGWSDLInterface *) anInterface endpoint: (MGWSDLEndpoint *) anEndpoint;

- (void) addEndpoint: (MGWSDLEndpoint *) anEndpoint;

@end