//
//  MGActionNotificationService.m
//  MGConnect
//
//  Created by Tony Stone on 4/1/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGActionNotificationService.h"
#import <CoreData/CoreData.h>
#import "MGConnect+EntitySettings.h"
#import "MGConnect+EntityAction.h"
#import "MGConnect+EntityActionNotification.h"

NSString * const MGActionKeyPathExecuting  = @"executing";
NSString * const MGActionKeyPathFinished   = @"finished";
NSString * const MGActionKeyPathReady      = @"ready";
NSString * const MGActionKeyPathCancelled  = @"cancelled";

@implementation MGActionNotificationService

static MGActionNotificationService * privateInstance;

+ (void) initialize {
    if (self == [MGActionNotificationService class]) {
        privateInstance = [[MGActionNotificationService alloc] init];
        
        //
        // Force any protocols to be loaded
        //
        (void) @protocol(MGEntityAction);
        (void) @protocol(MGEntityActionNotificationDelegate);
    }
}

+ (MGActionNotificationService *) privateInstance {
    return privateInstance;
}

+ (void) registerActionForNotification: (NSObject <MGEntityAction> *) anAction {
    
    [[self privateInstance] startObservingAction: anAction];
}

- (void) startObservingAction: (NSObject <MGEntityAction> *) anAction {
    [anAction addObserver: self forKeyPath: MGActionKeyPathExecuting  options: NSKeyValueObservingOptionNew  context: nil];
    [anAction addObserver: self forKeyPath: MGActionKeyPathFinished   options: NSKeyValueObservingOptionNew  context: nil];
    [anAction addObserver: self forKeyPath: MGActionKeyPathReady      options: NSKeyValueObservingOptionNew  context: nil];
    [anAction addObserver: self forKeyPath: MGActionKeyPathCancelled  options: NSKeyValueObservingOptionNew  context: nil];
}

- (void) stopObservingAction: (NSObject <MGEntityAction> *) anAction {
    [anAction removeObserver: self forKeyPath: MGActionKeyPathExecuting];
    [anAction removeObserver: self forKeyPath: MGActionKeyPathFinished];
    [anAction removeObserver: self forKeyPath: MGActionKeyPathReady];
    [anAction removeObserver: self forKeyPath: MGActionKeyPathCancelled];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject: (id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([object conformsToProtocol: @protocol(MGEntityAction)]) {
        
        NSObject <MGEntityAction>                     * action                     = object;
        NSObject <MGEntityActionNotificationDelegate> * actionNotificationDelegate = [[action entity] actionNotificationDelegate];
        
        if ([keyPath isEqualToString: MGActionKeyPathReady]) {
            
            ; // Nothing to do yet
            
        } else if ([keyPath isEqualToString: MGActionKeyPathExecuting]) {
            
            if (actionNotificationDelegate && [actionNotificationDelegate respondsToSelector: @selector(actionStarted:)]) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [actionNotificationDelegate actionStarted: action];
                });
            }
        } else if ([keyPath isEqualToString: MGActionKeyPathFinished]) {
            
            [self stopObservingAction: action];
            
            if (actionNotificationDelegate && [actionNotificationDelegate respondsToSelector: @selector(actionFinished:)]) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [actionNotificationDelegate actionFinished: action];
                });
            }
        } else if ([keyPath isEqualToString: MGActionKeyPathCancelled]) {
            
            [self stopObservingAction: action];
            
            if (actionNotificationDelegate && [actionNotificationDelegate respondsToSelector: @selector(actionCancelled:)]) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [actionNotificationDelegate actionCancelled: action];
                });
            }
        }
    }
}

@end
