//
//  MGEntityActionDefinition+Private.h
//  MGConnect
//
//  Created by Tony Stone on 4/10/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGConnect+EntityActionDefinition.h"

@class MGWSDLDescription;

@interface MGEntityActionDefinition ()

- (MGWSDLDescription *) wsdl: (NSString *) entityName;

@end
