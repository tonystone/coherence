//
//  GraphViewTemplate+Extensions.h
//  CloudBase
//
//  Created by Tony Stone on 12/15/11.
//  Copyright (c) 2011 Mobile Grid, Inc. All rights reserved.
//

#import "GraphViewTemplate.h"

@interface GraphViewTemplate (Extensions)

- (NSString *) titleForPlotIdentifier: (NSString *) identifier;
- (NSString *) colorSelectorForPlotIdentifier:(NSString *)identifier;

@end
