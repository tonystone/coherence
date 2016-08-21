//
//  MGWSDLBindingOperation.m
//  MGConnect
//
//  Created by Tony Stone on 4/10/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGWSDLBindingOperation.h"
#import "MGWSDLBinding.h"
#import "MGWSDLInterfaceOperation.h"
#import "MGWSDLBindingMessageReference.h"
#import "MGWSDLBindingFaultReference.h"

@implementation MGWSDLBindingOperation {
    MGWSDLInterfaceOperation * interfaceOperation;
    NSMutableDictionary      * bindingMessageReferences;
    NSMutableDictionary      * bindingFaultReferences;
    
    MGWSDLBinding __unsafe_unretained * parent;
}

- (MGWSDLInterfaceOperation *) interfaceOperation {
    return interfaceOperation;
}

- (NSDictionary *) bindingMessageReferences {
    return [NSDictionary dictionaryWithDictionary: bindingMessageReferences];
}

- (NSDictionary *) bindingFaultReferences {
    return [NSDictionary dictionaryWithDictionary: bindingFaultReferences];
}

- (MGWSDLBinding *) parent {
    return parent;
}

- (NSString *) description {
    return [self descriptionForLevel: 0];
}

- (NSString *) descriptionForLevel:(NSUInteger)level {
    
    NSMutableString * description = [NSMutableString stringWithFormat: @"<%@ : %p>:", NSStringFromClass([self class]), self];

    [description appendString: [self dictionaryString: extensionProperties      name: @"extensionProperties" level: level+1]];
    [description appendString: [self dictionaryString: extensionElements        name: @"extensionElements"   level: level+1]];
    [description appendString: [self dictionaryString: bindingMessageReferences name: @"messageReferences"   level: level+1]];
    [description appendString: [self dictionaryString: bindingFaultReferences   name: @"faultReferences"     level: level+1]];

    
    return description;
}

@end


@implementation MGWSDLBindingOperation (Initialization)

- (id) initWithName:(NSString *)name {
    [self doesNotRecognizeSelector: _cmd];
    
    return nil;
}

- (id) initWithName:(NSString *)name interfaceOperation: (MGWSDLInterfaceOperation *) anInterfaceOperation {
    
    NSParameterAssert(name != nil);
    NSParameterAssert(anInterfaceOperation != nil);
    
    if ((self = [super initWithName: name])) {
        interfaceOperation = anInterfaceOperation;
        
        bindingMessageReferences = [[NSMutableDictionary alloc] init];
        bindingFaultReferences   = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void) setParent:(MGWSDLBinding *__unsafe_unretained)aParent {
    
    //
    // Note: parent is required so you can't set it to nil
    //
    NSParameterAssert(aParent != nil);
    
    if (parent != aParent) {
        parent = aParent;
    }
}

- (void) addBindingMessageReference: (MGWSDLBindingMessageReference *) aBindingMessageReference {
    [bindingMessageReferences setValue: aBindingMessageReference forKey: [aBindingMessageReference name]];
    [aBindingMessageReference setParent: self];
}

- (void)   addBindingFaultReference: (MGWSDLBindingFaultReference *)   aBindingFaultReference {
    [bindingFaultReferences setValue: aBindingFaultReference forKey: [aBindingFaultReference name]];
    [aBindingFaultReference setParent: self];
}

@end