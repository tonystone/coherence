//
//  MGWSDLBindingMessageReference.m
//  MGResourceManager
//
//  Created by Tony Stone on 4/10/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGWSDLBindingMessageReference.h"
#import "MGWSDLInterfaceMessageReference.h"
#import "MGWSDLBindingOperation.h"

@implementation MGWSDLBindingMessageReference {
    MGWSDLInterfaceMessageReference            * interfaceMessageReference;
    MGWSDLBindingOperation __unsafe_unretained * parent;
}

- (MGWSDLInterfaceMessageReference *) interfaceMessageReference {
    return interfaceMessageReference;
}

- (MGWSDLBindingOperation *) parent {
    return parent;
}

- (NSString *) description {
    return [self descriptionForLevel: 0];
}

- (NSString *) descriptionForLevel:(NSUInteger)level {
    
    NSMutableString * description = [NSMutableString stringWithFormat: @"<%@ : %p>: interfaceMessageReference: %@", NSStringFromClass([self class]), self, [interfaceMessageReference name]];
    
    [description appendString: [self dictionaryString: extensionProperties      name: @"extensionProperties" level: level+1]];
    [description appendString: [self dictionaryString: extensionElements        name: @"extensionElements"   level: level+1]];

    return description;
}

@end

@implementation MGWSDLBindingMessageReference (Initialization)

- (id) initWithName: (NSString *) name {
    [self doesNotRecognizeSelector: _cmd];
    return nil;
}

- (id) initWithName: (NSString *) name interfaceMessageReference: (MGWSDLInterfaceMessageReference *) anInterfaceMessageReference {
    
    NSParameterAssert(name != nil);
    NSParameterAssert(anInterfaceMessageReference != nil);

    if ((self = [super initWithName: name])) {
        interfaceMessageReference  = anInterfaceMessageReference;
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