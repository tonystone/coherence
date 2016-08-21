//
//  MGWSDLComponent.m
//  MGConnect
//
//  Created by Tony Stone on 4/10/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGWSDLComponent.h"

@implementation MGWSDLComponent {
    NSString * name;
}

- (NSString *) name {
    return name;
}

- (NSString *) dictionaryString:(NSDictionary *) aDictionary name: (NSString *) aName level: (NSUInteger) level {
    
    NSMutableString * dictionaryString = [NSMutableString string];
    
    NSString * linePadding = [@"" stringByPaddingToLength: level * 3 withString: @"   " startingAtIndex: 0];
  
    [dictionaryString appendFormat: @"\r%@%@: {", linePadding, aName];
    
    for (NSString * key in [aDictionary allKeys]) {
        id object = [aDictionary objectForKey: key];

        NSString * objectDescription = nil;
        
        if ([object respondsToSelector: @selector(descriptionForLevel:)]) {
            objectDescription = [object descriptionForLevel: level + 1];
        } else {
            objectDescription = [object description];
        }
        
        [dictionaryString appendString: [NSString stringWithFormat: @"\r%@   %@ = %@", linePadding, key, objectDescription]];
    }
    
    [dictionaryString appendFormat: @"\r%@}", linePadding];
    
    return dictionaryString;
}

- (NSString *) descriptionForLevel: (NSUInteger) level {
    return @"";
}

@end

@implementation  MGWSDLComponent (Initialization)

- (id) ini {
    [self doesNotRecognizeSelector: _cmd];
    return nil;
}

- (id) initWithName: (NSString *) aName {
    
    if ((self = [super init])) {
        name = aName;
    }
    return self;
}
@end
