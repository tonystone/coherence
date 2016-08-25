//
//  MGConnectEditorRootController.m
//  ConnectEditor
//
//  Created by Tony Stone on 7/12/14.
//  Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//

#import "MGConnectEditorRootViewController.h"
#import "MGProjectItem.h"

// Message Logging
#import "MGMessageLog.h"
#import "MGMessageLogViewController.h"

// Managed Object Models
#import "MGManagedObjectModelReader.h"

// Web Services (WADL)
#import "MGWADLEditorViewController.h"
//#import "MGConnectConfigurationReader.h"
//#import "MGXMLReader.h"

@import Connect;

@interface MGConnectEditorRootViewController ()

    @property (weak) IBOutlet NSSplitView   * splitView;

    @property (weak) IBOutlet NSView        * rightView;
    @property (weak) IBOutlet NSView        * bottomView;

    @property (strong) IBOutlet NSOutlineView    * projectOutlineView;
    @property (strong) IBOutlet NSTreeController * projectOutlineController;
    @property (strong) IBOutlet NSMutableArray   * projectOutline;

@end

@implementation MGConnectEditorRootViewController {
        MGMessageLogViewController * _messageLogController;
        NSViewController           * _currentRightViewController;

        NSManagedObjectModel       * _managedObjectModel;
        MGXMLDocument              * _wadlDocument;
    
        BOOL                         _initialized;
    }

    - (id)init {
        return [self initWithNibName:@"MGConnectEditorMainMenu" bundle:nil];
    }

    - (NSArray *) getProjectOutline {

        NSArray * outline = @[ [MGProjectItem projectItem: @"CONNECT SETTINGS"  isLeaf: NO children:
                @[ [MGProjectItem projectItem: @"Global" isLeaf: YES children: nil],
                        [MGProjectItem projectItem: @"Entity" isLeaf: YES children: nil]]
                ],

                [MGProjectItem projectItem: @"DATA MODEL" isLeaf: NO children:
                        @[ [MGProjectItem projectItem: @"Mapping" isLeaf: YES children: nil]]
                ],

                [MGProjectItem projectItem: @"WEB SERVICES" isLeaf: NO children:
                        @[ [MGProjectItem projectItem: @"WADL" isLeaf: YES children: nil] ]
                ]
        ];
        return outline;
    }

    - (void) addMessageViewController {
        _messageLogController = [[MGMessageLogViewController alloc] init];

        NSView *subView = [_messageLogController view];
        [subView setTranslatesAutoresizingMaskIntoConstraints:NO];

        [_bottomView addSubview: subView];

        // Add constrains for the added view
        [_bottomView addConstraint: [NSLayoutConstraint constraintWithItem: subView
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem: _bottomView
                                                                 attribute:NSLayoutAttributeWidth
                                                                multiplier:1
                                                                  constant:0]];
        [_bottomView addConstraint: [NSLayoutConstraint constraintWithItem:subView
                                                                 attribute:NSLayoutAttributeHeight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:_bottomView
                                                                 attribute:NSLayoutAttributeHeight
                                                                multiplier:1
                                                                  constant:0]];
    }

    - (void) awakeFromNib {

        @synchronized(self) {
            
            if (!_initialized) {
                _initialized = YES;
                
                dispatch_async(dispatch_get_main_queue(), ^{

                    [self.projectOutline addObjectsFromArray: [self getProjectOutline]];
                    
                    [self.projectOutlineView setDelegate: self];
                    [self.projectOutlineView setDataSource: self];
                    
                    [self.projectOutlineView expandItem: nil expandChildren: YES];
                    //[self.projectOutlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:1] byExtendingSelection:NO];
                    
                    [self addMessageViewController];
                });
            }
        }

    }

    - (IBAction) importWADL:(id)sender {
        NSOpenPanel *panel = [NSOpenPanel openPanel];

        [panel setCanChooseFiles:YES];
        [panel setCanChooseDirectories:NO];
        [panel setAllowedFileTypes:[NSArray arrayWithObjects:@"wadl", @"xml", nil]];
        [panel setAllowsMultipleSelection:NO];

        NSInteger clicked = [panel runModal];

        if (clicked == NSFileHandlingPanelOKButton) {
            
            NSURL * url = [panel URL];
            
            [[MGMessageLog instance] logInfo: @"Importing WADL file at path: %@", [[url absoluteString] stringByRemovingPercentEncoding]];

            _wadlDocument = [MGXMLReader xmlDocumentFromURL: url elementClassPrefixes: @[@"MGConnect", @"MGWADL"]];

            NSLog(@"WADL: %@", _wadlDocument);
            
            if (_currentRightViewController && [_currentRightViewController isKindOfClass: [MGWADLEditorViewController class]]) {
                [(MGWADLEditorViewController *)_currentRightViewController setWADLDocument: _wadlDocument];
            }
        }
    }

    - (IBAction) importManagedObjectModel:(id)sender {
        NSOpenPanel *panel = [NSOpenPanel openPanel];

        [panel setCanChooseFiles:YES];
        [panel setCanChooseDirectories:NO];
        [panel setAllowedFileTypes:[NSArray arrayWithObjects:@"xcdatamodeld", @"xcdatamodel", nil]];
        [panel setAllowsMultipleSelection:NO];

        NSInteger clicked = [panel runModal];

        if (clicked == NSFileHandlingPanelOKButton) {

            NSURL * url = [panel URL];

            [[MGMessageLog instance] logInfo: @"Importing NSManagedObjectModel file at path: %@", [[url absoluteString] stringByRemovingPercentEncoding]];

            if ([url isFileURL]) {
                NSNumber *isDirectory;

                BOOL success = [url getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:nil];

                if ([[url pathExtension] isEqualToString: @"xcdatamodeld"] && (success && isDirectory)) {
                    // Get the model object from the directory if just one, else you have to ask which one to choose.

                    NSFileManager * fileManager = [NSFileManager defaultManager];

                    NSArray *keys = [NSArray arrayWithObjects: NSURLIsDirectoryKey, NSURLIsPackageKey, NSURLLocalizedNameKey, NSURLFileResourceTypeKey, nil];

                    NSDirectoryEnumerator * enumerator = [fileManager enumeratorAtURL: url
                                                           includingPropertiesForKeys: keys
                                                                              options: (NSDirectoryEnumerationSkipsPackageDescendants |
                                                                                      NSDirectoryEnumerationSkipsHiddenFiles)
                                                                         errorHandler:^BOOL(NSURL *url, NSError *error) {

                                [[MGMessageLog instance] logError: @"Error reading model file: %@", [error localizedDescription]];

                                return YES;
                            }];
                    NSArray * allObjects = [enumerator allObjects];

                    if ([allObjects count] == 1) {
                        url = [allObjects lastObject];
                    } else {
                        [[MGMessageLog instance] logError: @"Error: Invalid model format."];
                    }
                }
                _managedObjectModel = [MGManagedObjectModelReader managedObjectModelFromURL: url];
            }
        }
    }

#pragma mark - NSOutlineViewDelegate

    - (void)outlineViewSelectionDidChange:(NSNotification *)notification {
        NSOutlineView * outlineView = [notification object];

        id selectedItem = [outlineView itemAtRow: [outlineView selectedRow]];

        if (selectedItem) {

            if ([[selectedItem displayName] isEqualToString: @"WADL"]) {
                _currentRightViewController = [[MGWADLEditorViewController alloc] init];

                [(MGWADLEditorViewController *)_currentRightViewController setWADLDocument: _wadlDocument];
            } else {
                if (_currentRightViewController) {
                    [[_currentRightViewController view] removeFromSuperview];
                }
                _currentRightViewController = nil;
            }

            if (_currentRightViewController) {
                NSView *subView = [_currentRightViewController view];
                [subView setTranslatesAutoresizingMaskIntoConstraints:NO];

                [_rightView addSubview: [_currentRightViewController view]];

                // Add constrains for the added view
                [_rightView addConstraint: [NSLayoutConstraint constraintWithItem: subView
                                                                        attribute:NSLayoutAttributeWidth
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem: _rightView
                                                                        attribute:NSLayoutAttributeWidth
                                                                       multiplier:1
                                                                         constant:0]];
                [_rightView addConstraint: [NSLayoutConstraint constraintWithItem:subView
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:_rightView
                                                                        attribute:NSLayoutAttributeHeight
                                                                       multiplier:1
                                                                         constant:0]];
            }
        }

    }


    - (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item{
        return ![self isHeader:item];
    }

    - (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item {

        NSView * view = nil;
        NSTextField * textField = nil;

        if ([self isHeader: item]) {
            view = [outlineView makeViewWithIdentifier:@"HeaderCell" owner: nil];

            textField  = [[view subviews] objectAtIndex: 0];
        } else {
            view = [outlineView makeViewWithIdentifier:@"DataCell" owner: nil];

            textField  = [[view subviews] objectAtIndex: 1];
        }
        [textField setStringValue: [item displayName]];

        return view;
    }

    - (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item{
        // This converts a group to a header which influences its style
        return [self isHeader:item];
    }

#pragma mark - NSOutlineViewDataSource

    - (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
        return item ? [[item children] count] : [_projectOutline count];
    }

    - (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
    {
        return [[item children] count] > 0;
    }

    - (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
    {
        return item ? [[item children] objectAtIndex: index] : [_projectOutline objectAtIndex: index];
    }

#pragma mark - Helpers

    - (BOOL) isHeader:(id)item{

        return ![item isLeaf];
    }

@end
