//
//  MGWSDLExtensionElement.m
//  MGConnect
//
//  Created by Tony Stone on 4/11/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGWSDLExtensionElement.h"

@implementation MGWSDLExtensionElement {
    NSString * element;
    NSString * type;
    BOOL       required;
    
    id         value;
}

- (NSString *) element {
    return element;
}

- (NSString *) type {
    return type;
}

- (BOOL) required {
    return required;
}

- (id) value {
    return value;
}

- (NSString *) description {
    return [self descriptionForLevel: 0];
}

- (NSString *) descriptionForLevel:(NSUInteger)level {
    
    NSMutableString * description = [NSMutableString stringWithFormat: @"<%@ : %p>: element: %@ name: %@ type: %@ required: %@ value: %@", NSStringFromClass([self class]), self, element, [self name], type, required ? @"YES" : @"NO", value ? value : @""];
    
    return description;
}

@end

@implementation MGWSDLExtensionElement (Initialization)

- (id) initWithName:(NSString *)name {
    [self doesNotRecognizeSelector: _cmd];
    return nil;
}

- (id) initWithName:(NSString *)name element: (NSString *) anElement type: (NSString *) aType required: (BOOL) isRequired {
    
    NSParameterAssert(name != nil);
    NSParameterAssert(anElement != nil);
    NSParameterAssert(aType != nil);
    
    if ((self = [super initWithName: name])) {
        element  = anElement;
        type     = aType;
        required = isRequired;
    }
    return self;
}

- (void) setValue:(id)aValue {
    if (value != aValue) {
        value = aValue;
    }
}

@end

