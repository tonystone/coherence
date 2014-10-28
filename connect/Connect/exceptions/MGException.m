//
//  MGException.m
//  MGConnect
//
//  Created by Tony Stone on 3/28/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGException.h"
#import <Connect-Common/MGTraceLog.h>

@implementation MGException

- (void) raise {
    
    LogError(@"%@ : %@", [self name], [self reason]);
    
    [super raise];
}

@end
