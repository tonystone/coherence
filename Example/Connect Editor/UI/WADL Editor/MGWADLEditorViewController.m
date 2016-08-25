//
//  MGWADLEditorViewController.m
//  ConnectEditor
//
//  Created by Tony Stone on 7/12/14.
//  Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//

#import "MGWADLEditorViewController.h"
#import "MGXMLReader.h"
#import "MGXMLDocument.h"
#import "MGWADL.h"
#import "MGWADL+Extensions.h"

#import "MGWADLEditorResourcesViewController.h"

@interface MGWADLEditorViewController ()

    @property (strong) IBOutlet NSStackView * resourcesStackView;

@end

@implementation MGWADLEditorViewController {
        MGXMLDocument * _wadlDocument;
    
        NSMutableArray * _resourcesViewControllers;
    }


    - (instancetype)init {
        return [self initWithNibName:@"MGWADLEditorViewController" bundle:nil];
    }

    - (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {

        self = [super initWithNibName: nibNameOrNil bundle: nibBundleOrNil];
        if (self) {
            _resourcesViewControllers = [[NSMutableArray alloc] init];
        }
        return self;
    }

    - (void) awakeFromNib {

        if (_wadlDocument) {
            
            [self performSelector: @selector(displayWADLModel) withObject: nil afterDelay: 0.1];
        }

    }

    - (void) displayWADLModel {
    
        [_resourcesViewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [_resourcesStackView removeView: [obj view]];
        }];
         
        for (MGWADLResources * resources in [[[_wadlDocument elements] objectAtIndex: 0] resources]) {
        
            MGWADLEditorResourcesViewController * viewController = [[MGWADLEditorResourcesViewController alloc] init];
        
            [viewController setResources: resources];
            
            [_resourcesViewControllers addObject: viewController];
            [_resourcesStackView addView: [viewController view] inGravity: NSStackViewGravityTop];
            
            [_resourcesStackView insertView: [viewController view] atIndex:0 inGravity:NSStackViewGravityBottom];
            //[_resourcesStackView layoutIfNeeded];
            NSLog(@"%f - %d\r\n", NSHeight( [viewController view].frame), [[viewController view] hasAmbiguousLayout]);
        }
    }

    - (void) setWADLDocument: (MGXMLDocument *) wadlDocument {
    
        if (_wadlDocument != wadlDocument) {
            _wadlDocument = wadlDocument;
        
            [self displayWADLModel];
        }
    }

    - (NSArray *) resourceListFromResources: (MGWADLResources *) wadlResources {

        NSMutableArray * resourceList = [[NSMutableArray alloc] init];

        for (MGWADLResource * resource  in [wadlResources resources]) {
            [resourceList addObject: resource];

            [resourceList addObjectsFromArray: [self resourceListFromResource: [resource resources]]];
        }

        return resourceList;
    }

    - (NSArray *) resourceListFromResource: (NSArray *) resources {

        NSMutableArray * resourceList = [[NSMutableArray alloc] init];

        for (MGWADLResource * resource  in resources) {
            [resourceList addObject: resource];

            [resourceList addObjectsFromArray: [self resourceListFromResource: [resource resources]]];
        }

        return resourceList;
    }

@end
