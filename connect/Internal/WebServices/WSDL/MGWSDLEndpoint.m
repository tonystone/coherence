//
//  MGWSDLEndpoint.m
//  MGConnect
//
//  Created by Tony Stone on 4/10/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGWSDLEndpoint.h"
#import "MGWSDLBinding.h"
#import "MGWSDLService.h"

@implementation MGWSDLEndpoint {
    
    MGWSDLBinding * binding;
    NSString      * address;
    
    MGWSDLService __unsafe_unretained * parent;
}

- (MGWSDLBinding *) binding {
    return binding;
}

- (MGWSDLService *) parent {
    return parent;
}

- (NSString *) address {
    return address;
}

- (NSString *) description {
    return [self descriptionForLevel: 0];
}

- (NSString *) descriptionForLevel:(NSUInteger)level {
    
    NSMutableString * description = [NSMutableString stringWithFormat: @"<%@ : %p>: binding: %@ address: %@", NSStringFromClass([self class]), self, [binding name], address];
 
    [description appendString: [self dictionaryString: extensionProperties name: @"extensionProperties" level: level+1]];
    [description appendString: [self dictionaryString: extensionElements   name: @"extensionElements"   level: level+1]];
    
    return description;
}

@end


@implementation MGWSDLEndpoint (Initialization)

- (id) initWithName:(NSString *)name {
    [self doesNotRecognizeSelector: _cmd];
    return nil;
}

- (id) initWithName: (NSString *) name binding: (MGWSDLBinding *) aBinding {
    
    NSParameterAssert(name != nil);
    NSParameterAssert(aBinding != nil);
    
    if ((self = [super initWithName: name])) {
        binding = aBinding;
    }
    return self;
}

- (void) setAddress: (NSString *) anAddress {
    if (address != anAddress) {
        address = anAddress;
    }
}

- (void) setParent:(MGWSDLService *__unsafe_unretained)aParent {
    
    //
    // Note: parent is required so you can't set it to nil
    //
    NSParameterAssert(aParent != nil);
    
    if (parent != aParent) {
        parent = aParent;
    }
}

@end