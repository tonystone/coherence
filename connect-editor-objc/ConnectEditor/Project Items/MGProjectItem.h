//
//  MGProjectItem.h
//  ConnectEditor
//
//  Created by Tony Stone on 7/12/14.
//  Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MGProjectItem : NSObject

+ (MGProjectItem *) projectItem:(NSString *) displayName isLeaf:(BOOL) isLeaf children: (NSArray *) children ;

@property (copy) NSString * displayName;
@property (assign) BOOL isLeaf;
@property (strong) NSMutableArray * children;

@end
