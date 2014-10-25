//
//  Server+Exentions.h
//  CloudBase
//
//  Created by Tony Stone on 10/10/11.
//  Copyright 2011 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Server.h"

@class Instance;

@interface Server (Extensions)

- (Instance *) currentInstance;
- (Instance *) nextInstance;
- (BOOL) active;
@end
