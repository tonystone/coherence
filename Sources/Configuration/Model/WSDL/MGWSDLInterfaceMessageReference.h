//
//  MGWSDLMessageReference.h
//  MGConnect
//
//  Created by Tony Stone on 4/10/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGWSDLComponent.h"
#import "MGWSDL+Types.h"

@class MGWSDLElementDeclaration;
@class MGWSDLInterfaceOperation;

@interface MGWSDLInterfaceMessageReference : MGWSDLComponent

- (NSString *)                 messageLabel;
- (MGWSDLMessageDirection)     direction;
- (MGWSDLMessageContentModel)  messageContentModel;
- (MGWSDLElementDeclaration *) elementDeclaration;
- (MGWSDLInterfaceOperation *) parent;

@end


@interface MGWSDLInterfaceMessageReference (Initialization)

- (id) initWithName:(NSString *)name messageLabel: (NSString *) aMessageLabel direction: (MGWSDLMessageDirection) aDirection messageContentModel: (MGWSDLMessageContentModel) aMessageContentModel;
- (void) setParent: (MGWSDLInterfaceOperation *) aParent;

- (void) setElementDeclaration: (MGWSDLElementDeclaration *) anElementDeclaration;

@end