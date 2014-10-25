//
//  MGWADLEditorResourcesViewController.m
//  ConnectEditor
//
//  Created by Tony Stone on 7/14/14.
//  Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//

#import "MGWADLEditorResourcesViewController.h"

@interface MGWADLEditorResourcesViewController ()

    @property (strong) IBOutlet NSTextField * resourcesBaseTextField;
    @property (strong) IBOutlet NSStackView * resourceStackView;

@end

@implementation MGWADLEditorResourcesViewController {
       MGWADLResources * _resources;
    }

    - (instancetype)init {
        return [self initWithNibName:@"MGWADLEditorResourcesViewController" bundle:nil];
    }

    - (void) setResources:(MGWADLResources *)newValue {
        if (newValue != _resources) {
            _resources = newValue;
            
            [_resourcesBaseTextField setStringValue: [_resources base]];
            [_resourcesBaseTextField setNeedsDisplay];
        }
    }

@end
