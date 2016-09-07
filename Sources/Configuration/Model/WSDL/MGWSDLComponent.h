//
//  MGWSDLComponent.h
//  MGConnect
//
//  Created by Tony Stone on 4/10/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MGWSDLComponent : NSObject

- (NSString *) name;

- (NSString *) dictionaryString:(NSDictionary *) aDictionary name: (NSString *) name level: (NSUInteger) level;
- (NSString *) descriptionForLevel: (NSUInteger) level;

@end


@interface MGWSDLComponent (Initialization)

- (id) initWithName: (NSString *) name;

@end