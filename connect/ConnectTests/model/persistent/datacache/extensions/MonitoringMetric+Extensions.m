//
//  MonitoringMetric+Extensions.m
//  CloudBase
//
//  Created by Tony Stone on 11/4/11.
//  Copyright (c) 2011 Mobile Grid, Inc. All rights reserved.
//

#import "MonitoringMetric+Extensions.h"
#import "MonitoringMetricData.h"
#import "GraphViewTemplate+Extensions.h"

@implementation MonitoringMetric (Extensions)

- (MonitoringMetricData *) data {
    return [[self valueForKey: @"fetchData"] lastObject];
}
- (GraphViewTemplate *) graphViewTemplate {
    
    GraphViewTemplate * pluginTypeTemplate = nil;
    GraphViewTemplate * pluginTemplate     = nil;
    GraphViewTemplate * defaultTemplate    = nil;
    
    NSArray  * templates = [self valueForKey: @"fetchGraphViewTemplates"];

    for (GraphViewTemplate * template in templates) {
        NSString * templateName = [template name];  // Force a read from the database, otherwise the isEqual will fail
        
        (void) templateName;
        
        if      ([templateName isEqualToString: [self pluginType]])  { pluginTypeTemplate = template; }
        else if ([templateName isEqualToString: [self plugin]])      { pluginTemplate     = template; }
        else if ([templateName isEqualToString:  @"default"])        { defaultTemplate    = template; }
    }
    
    // The most specific tmeplate is always 
    // used first followed by one for the 
    // plugin then fail to the default.
    if      (pluginTypeTemplate) return pluginTypeTemplate;
    else if (pluginTemplate)     return pluginTemplate;
    else                         return defaultTemplate;
}
- (Instance *) instance {
    return [[self valueForKey: @"fetchInstance"] lastObject];
}

@end
