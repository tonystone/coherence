//
//  MGWSDLInterfaceFaultReference.m
//  MGResourceManager
//
//  Created by Tony Stone on 4/10/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGWSDLInterfaceFaultReference.h"
#import "MGWSDLInterfaceFault.h"
#import "MGWSDLInterfaceOperation.h"

@implementation MGWSDLInterfaceFaultReference {
    NSString *             messageLabel;
    MGWSDLMessageDirection direction;
    MGWSDLInterfaceFault * interfaceFault;
    
    MGWSDLInterfaceOperation __unsafe_unretained * parent;
}

- (NSString *) messageLabel {
    return messageLabel;
}

- (MGWSDLMessageDirection) direction {
    return direction;
}

- (MGWSDLInterfaceFault *) interfaceFault {
    return interfaceFault;
}

- (MGWSDLInterfaceOperation *) parent {
    return parent;
}

@end


@implementation MGWSDLInterfaceFaultReference (Initialization)

- (id) initWithInterfaceFault: (MGWSDLInterfaceFault *) anInterfaceFault messageLabel: (NSString *) aMessageLabel direction: (MGWSDLMessageDirection) aDirection {
    
    NSParameterAssert(anInterfaceFault != nil);
    NSParameterAssert(aMessageLabel != nil);
    NSParameterAssert(aDirection != nil);
    
    if ((self = [super init])) {
        interfaceFault = anInterfaceFault;
        messageLabel   = aMessageLabel;
        direction      = aDirection;
    }
    return self;
}

- (void) setParent: (MGWSDLInterfaceOperation *) aParent {
    
    //
    // Note: parent is required so you can't set it to nil
    //
    NSParameterAssert(aParent != nil);
    
    if (parent != aParent) {
        parent = aParent;
    }
}

@end