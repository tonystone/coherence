//
//  MGWSDLBindingFaultReference.m
//  MGResourceManager
//
//  Created by Tony Stone on 4/10/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGWSDLBindingFaultReference.h"
#import "MGWSDLInterfaceFaultReference.h"
#import "MGWSDLBindingOperation.h"

@implementation MGWSDLBindingFaultReference {
    MGWSDLInterfaceFaultReference * interfaceFaultReference;
    
    MGWSDLBindingOperation __unsafe_unretained * parent;
}

- (MGWSDLInterfaceFaultReference *) interfaceFaultReference {
    return interfaceFaultReference;
}

- (MGWSDLBindingOperation *) parent {
    return parent;
}

@end

@implementation MGWSDLBindingFaultReference (Initialization)

- (id) initWithName: (NSString *) name {
    [self doesNotRecognizeSelector: _cmd];
    return nil;
}

- (id) initWithName: (NSString *) name interfaceFaultReference: (MGWSDLInterfaceFaultReference *) anInterfaceFaultReference {
    
    NSParameterAssert(anInterfaceFaultReference != nil);
    
    if ((self = [super init])) {
        interfaceFaultReference  = anInterfaceFaultReference;
    }
    return self;
}

- (void) setParent: (MGWSDLBindingOperation __unsafe_unretained *) aParent {
    
    //
    // Note: parent is required so you can't set it to nil
    //
    NSParameterAssert(aParent != nil);
    
    if (parent != aParent) {
        parent = aParent;
    }
}

@end