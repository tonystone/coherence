//
//  AppDelegate.h
//  Connect Example App
//
//  Created by Tony Stone on 10/21/14.
//  Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (NSManagedObjectModel *) managedObjectModel;

@end

