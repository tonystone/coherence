//
//  MGWSDLInterfaceOperation.h
//  MGConnect
//
//  Created by Tony Stone on 4/10/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGWSDLComponent.h"

/**
 Message Exchange Patterns
 */
typedef NSString * MGWSDLMessageExchangePattern;

extern MGWSDLMessageExchangePattern MGWSDLMessageExchangePatternInOnly;
extern MGWSDLMessageExchangePattern MGWSDLMessageExchangePatternRobustInOnly;
extern MGWSDLMessageExchangePattern MGWSDLMessageExchangePatternInOut;
extern MGWSDLMessageExchangePattern MGWSDLMessageExchangePatternInOptOut;
extern MGWSDLMessageExchangePattern MGWSDLMessageExchangePatternOutIn;
extern MGWSDLMessageExchangePattern MGWSDLMessageExchangePatternOutOptIn;
extern MGWSDLMessageExchangePattern MGWSDLMessageExchangePatternOutOnly;
extern MGWSDLMessageExchangePattern MGWSDLMessageExchangePatternRobustOutOnly;

@class MGWSDLInterface;
@class MGWSDLInterfaceFaulReferences;
@class MGWSDLInterfaceMessageReference;
@class MGWSDLInterfaceFaultReference;

@interface MGWSDLInterfaceOperation : MGWSDLComponent

- (MGWSDLMessageExchangePattern) messageExchangePattern;
- (NSString *) style;
- (MGWSDLInterface *) parent;

@end


@interface MGWSDLInterfaceOperation (Initialization)

- (id) initWithName: (NSString *) name messageExchangePattern: (MGWSDLMessageExchangePattern) aMessageExchangePattern;

- (void) setParent: (MGWSDLInterface __unsafe_unretained *) aParent;

- (void) addInterfaceMessageReference: (MGWSDLInterfaceMessageReference *) anInterfaceMessageReference;
- (void)   addInterfaceFaultReference: (MGWSDLInterfaceFaultReference *)   anInterfaceFaultReference;

@end