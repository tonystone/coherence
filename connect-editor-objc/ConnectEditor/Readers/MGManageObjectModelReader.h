//
//  MGManageObjectModelReader.h
//  MGConnectConfigurationEditor
//
//  Created by Tony Stone on 7/6/14.
//  Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface MGManageObjectModelReader : NSObject

    + (NSManagedObjectModel *) manageObjectModelFromURL: (NSURL *) aURL;

@end
