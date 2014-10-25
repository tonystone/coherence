//
//  AppDelegate.m
//  ConnectEditor
//
//  Created by Tony Stone on 7/11/14.
//  Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//

#import "MGConnectEditorAppDelegate.h"
#import "MGConnectEditorRootViewController.h"

@interface MGConnectEditorAppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (strong) IBOutlet MGConnectEditorRootViewController * rootViewController;

@end

@implementation MGConnectEditorAppDelegate
            
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    NSLog(@"Application loaded");
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
