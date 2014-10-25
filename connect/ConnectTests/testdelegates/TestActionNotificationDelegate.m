//
//  TestActioNotificationDelegate.m
//  MGConnectTest
//
//  Created by Tony Stone on 4/1/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "TestActionNotificationDelegate.h"
#import "MGConnect+EntityActionNotification.h"

@implementation TestActionNotificationDelegate

- (id) init {
    if ((self = [super init])) {
        NSLog(@"%@ created", NSStringFromClass([self class]));
    }
    
    return self;
}

- (void) actionStarted:(NSObject<MGEntityAction> *)anAction {
    
}

@end
