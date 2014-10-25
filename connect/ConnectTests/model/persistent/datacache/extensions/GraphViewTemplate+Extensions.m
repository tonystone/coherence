//
//  GraphViewTemplate+Extensions.m
//  CloudBase
//
//  Created by Tony Stone on 12/15/11.
//  Copyright (c) 2011 Mobile Grid, Inc. All rights reserved.
//

#import "GraphViewTemplate+Extensions.h"

@implementation GraphViewTemplate (Extensions)
- (NSString *) titleForPlotIdentifier:(NSString *)identifier {
   return [(NSDictionary *)[self plotTitles] objectForKey: identifier];
}
- (NSString *) colorSelectorForPlotIdentifier:(NSString *)identifier {
    return [(NSDictionary *)[self plotLineColors] objectForKey: identifier];
}
@end
