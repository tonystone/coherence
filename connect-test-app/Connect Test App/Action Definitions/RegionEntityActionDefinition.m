//
//  RegionEntityActionDefinition.m
//  MGConnectTest
//
//  Created by Tony Stone on 4/13/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "RegionEntityActionDefinition.h"

@implementation RegionEntityActionDefinition

- (NSDictionary *) actionLocations {
    
    return @{MGEntityActionList:      @"/regions",
             MGEntityActionRead:      @"/regions/{regionId}",
             };
}

- (id) primaryKey {
    return @"regionId";
}

- (NSString *) mappingRoot {
    return @"/regions/region";
}
- (NSDictionary *) mapping {
    
    //  keyPath <- xPath
    /*
         @"textDescription":            @"description",
         @"createdAt":                  @"dateTime(created_at,'yyyy/MM/dd HH:mm:ss Z')",
         @"updatedAt":                  @"dateTime(updated_at,'yyyy/MM/dd HH:mm:ss Z')",
         @"resourceReference":          @"links/link[@rel='self']/@href",
         @"deploymentReference":        @"links/link[@rel='deployment']/@href",
         @"currentInstanceReference":   @"links/link[@rel='current_instance']/@href",
         @"nextInstanceReference":      @"links/link[@rel='next_instance']/@href"
     */
    
    return @{@"regionId": @"RegionID",
             @"name":     @"RegionName"};
}

@end
