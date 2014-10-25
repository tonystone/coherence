//
//  MGWSDLExtendableComponent.h
//  MGResourceManager
//
//  Created by Tony Stone on 4/11/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGWSDLComponent.h"

@class MGWSDLExtensionElement;

@interface MGWSDLExtendableComponent : MGWSDLComponent {
@package
    NSMutableDictionary * extensionProperties;
    NSMutableDictionary * extensionElements;
}

- (NSDictionary *) extensionProperties;
- (NSDictionary *) extensionElements;

@end

@interface MGWSDLExtendableComponent (Initialization)

- (id) initWithName:(NSString *)name;

- (void) setExtensionPropertyValue: (id) aValue forKey: (NSString *) aKey;
- (void) addExtensionElement: (MGWSDLExtensionElement *) anExtensionElement;

@end
