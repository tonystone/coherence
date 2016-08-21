//
//  MGWSDLBindingFault.m
//  MGConnect
//
//  Created by Tony Stone on 4/10/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGWSDLBindingFault.h"
#import "MGWSDLInterfaceFault.h"
#import "MGWSDLBinding.h"

@implementation MGWSDLBindingFault {
    MGWSDLInterfaceFault              * interfaceFault;
    MGWSDLBinding __unsafe_unretained * parent;
}

- (MGWSDLInterfaceFault *) interfaceFault {
    return interfaceFault;
}

- (MGWSDLBinding *) parent {
    return parent;
}

@end

@implementation MGWSDLBindingFault (Initialization)

- (id) initWithName: (NSString *) name {
    [self doesNotRecognizeSelector: _cmd];
    return nil;
}

- (id) initWithName: (NSString *) name interfaceFault: (MGWSDLInterfaceFault *) anInterfaceFault {

    NSParameterAssert(name != nil);
    NSParameterAssert(anInterfaceFault != nil);
    
    if ((self = [super initWithName: name])) {
        
        interfaceFault = anInterfaceFault;
    }
    return self;
}

- (void) setParent: (MGWSDLBinding __unsafe_unretained *) aParent {
    
    //
    // Note: parent is required so you can't set it to nil
    //
    NSParameterAssert(aParent != nil);
    
    if (parent != aParent) {
        parent = aParent;
    }
}

@end
