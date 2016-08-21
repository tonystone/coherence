//
//  MGObjectMapper.h
//  MGConnect
//
//  Created by Tony Stone on 4/18/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MGObjectMapper <NSObject>

    /**
     Initialize this mapper with the entity description and mapping data if present.
     */
    - (id) initWithObjectClass: (Class) objectClass objectAllocationBlock: (id (^)(void)) objectAllocationBlockOrNil objectMapping: (NSDictionary *) objectMapping objectRoot: (NSString *) objectRootOrNil;

    /**
     Maps the input data to a local array of objects
     */
    - (NSArray *) map: (NSData *) data;

    /**
     Maps the local objects to an NSData representation.
     */
    - (NSData *) reverseMap: (NSArray *) objects;

@end


