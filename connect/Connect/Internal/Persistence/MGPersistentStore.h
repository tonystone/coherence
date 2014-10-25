//
// Created by Tony Stone on 8/22/14.
// Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol MGPersistentStore <NSObject>
    + (NSString *) storeType;
@end