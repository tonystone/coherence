//
//  MGWSDLExtendableComponent.m
//  MGConnect
//
//  Created by Tony Stone on 4/11/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGWSDLExtendableComponent.h"
#import "MGWSDLExtensionElement.h"

@implementation MGWSDLExtendableComponent

- (NSDictionary *) extensionProperties {
    return [NSDictionary dictionaryWithDictionary: extensionProperties];
}

- (NSDictionary *) extensionElements {
    return [NSDictionary dictionaryWithDictionary: extensionElements];
}

@end

@implementation MGWSDLExtendableComponent (Initialization)

- (id) initWithName:(NSString *)name {
    
    if ((self = [super initWithName: name])) {
        extensionElements   = [[NSMutableDictionary alloc] init];
        extensionProperties = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void) setExtensionPropertyValue:(id)aValue forKey:(NSString *)aKey {
    [extensionProperties setObject: aValue forKey: aKey];
}

- (void) addExtensionElement: (MGWSDLExtensionElement *) anExtensionElement {
    [extensionElements setValue: anExtensionElement forKey: [anExtensionElement name]];
}

@end
