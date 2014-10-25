//
//  MGWSDLBinding.m
//  MGConnect
//
//  Created by Tony Stone on 4/10/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGWSDLBinding.h"
#import "MGWSDLBindingFault.h"
#import "MGWSDLBindingOperation.h"

@implementation MGWSDLBinding {
    NSString            * type;
    NSMutableDictionary * bindingOperations;
    NSMutableDictionary * bindingFaults;
    
    MGWSDLInterface __unsafe_unretained * interface;
}

- (NSString *) type {
    return type;
}

- (MGWSDLInterface *) interface {
    return interface;
}

- (NSDictionary *) bindingFaults {
    return [NSDictionary dictionaryWithDictionary: bindingFaults];
}

- (NSDictionary *) bindingOperations {
    return [NSDictionary dictionaryWithDictionary: bindingOperations];
}

- (NSString *) description {
    return [self descriptionForLevel: 0];
}

- (NSString *) descriptionForLevel:(NSUInteger)level {
 
    NSMutableString * description = [NSMutableString stringWithFormat: @"<%@ : %p>: type: %@", NSStringFromClass([self class]), self, type];
    
    [description appendString: [self dictionaryString: extensionProperties name: @"extensionProperties" level: level+1]];
    [description appendString: [self dictionaryString: extensionElements   name: @"extensionElements"   level: level+1]];
    [description appendString: [self dictionaryString: bindingOperations   name: @"bindingOperations"   level: level+1]];
    [description appendString: [self dictionaryString: bindingFaults       name: @"bindingFaults"       level: level+1]];

    return description;
}

@end


@implementation MGWSDLBinding (Initialization)

- (id) initWithName: (NSString *) name {
    [self doesNotRecognizeSelector: _cmd];
    return nil;
}

- (id) initWithName:(NSString *)name type: (NSString *) aType {
    
    NSParameterAssert(name != nil);
    NSParameterAssert(aType != nil);
    
    if ((self = [super initWithName: name])) {
        type = aType;
        
        bindingOperations = [[NSMutableDictionary alloc] init];
        bindingFaults     = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void) setInterface: (MGWSDLInterface __unsafe_unretained *) anInterface {
    if (anInterface != interface) {
        interface = anInterface;
    }
}

- (void) addBindingFault: (MGWSDLBindingFault *) aBindingFault {
    [bindingFaults setObject: aBindingFault forKey: [aBindingFault name]];
    [aBindingFault setParent: self];
}

- (void) addBindingOperation: (MGWSDLBindingOperation *) aBindingOperation {
    [bindingOperations setObject: aBindingOperation forKey: [aBindingOperation name]];
    [aBindingOperation setParent: self];
}

@end