//
//  MGObjectProtocolValidator.h
//  Connect
//
//  Created by Tony Stone on 5/30/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MGClassProtocolValidator : NSObject

+ (void) validateClass: (Class) class forProtocols: (NSArray *) protocols;

@end
