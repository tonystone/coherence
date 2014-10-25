//
//  MGProjectItem.m
//  ConnectEditor
//
//  Created by Tony Stone on 7/12/14.
//  Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//

#import "MGProjectItem.h"

@implementation MGProjectItem

+ (MGProjectItem *) projectItem:(NSString *) displayName isLeaf:(BOOL) isLeaf children: (NSArray *) children {
    
    MGProjectItem * result = [MGProjectItem new];
    result.children = [[NSMutableArray alloc] init];
    result.displayName = displayName;
    result.isLeaf = isLeaf;
    
    if (children) {
        [result.children addObjectsFromArray: children];
    }
    
    return result;
}

@end
