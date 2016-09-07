//
//  MGWSDLInterfaceFault.h
//  MGConnect
//
//  Created by Tony Stone on 4/10/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGWSDLExtendableComponent.h"
#import "MGWSDL+Types.h"

@class MGWSDLInterface;
@class MGWSDLElementDeclaration;

@interface MGWSDLInterfaceFault : MGWSDLExtendableComponent

- (MGWSDLMessageContentModel)  messageContentModel;
- (MGWSDLElementDeclaration *) elementDeclaration;
- (MGWSDLInterface *) parent;

@end

@interface MGWSDLInterfaceFault (Initialization)

- (id) initWithName: (NSString *) name messageContentModel: (MGWSDLMessageContentModel) aMessageContentModel;
- (void) setParent: (MGWSDLInterface *) aParent;

- (void) setElementDeclaration: (MGWSDLElementDeclaration *) anElementDeclaration;

@end