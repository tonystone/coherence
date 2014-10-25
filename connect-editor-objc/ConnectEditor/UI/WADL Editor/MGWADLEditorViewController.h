//
//  MGWADLEditorViewController.h
//  ConnectEditor
//
//  Created by Tony Stone on 7/12/14.
//  Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MGXMLDocument;

@interface MGWADLEditorViewController : NSViewController

- (void) setWADLDocument: (MGXMLDocument *) wadlDocument;

@end
