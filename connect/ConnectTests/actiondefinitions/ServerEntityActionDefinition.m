//
//  ServerEntityActionDefinition.m
//  MGConnectTest
//
//  Created by Tony Stone on 4/13/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "ServerEntityActionDefinition.h"

@implementation ServerEntityActionDefinition

- (NSDictionary *) actionLocations {
    
    return @{MGEntityActionList:      @"/servers",                       
             MGEntityActionRead:      @"/servers/{serverID}",            
             MGEntityActionInsert:    @"/servers",                     
             MGEntityActionUpdate:    @"/servers/{serverID}",          
             MGEntityActionDelete:    @"/servers/{serverID}",          
             @"clone":     @{@"POST": @"/servers/{serverID}/clone"},    
             @"launch":    @{@"POST": @"/servers/{serverID}/launch"},  
             @"terminate": @{@"POST": @"/servers/{serverID}/terminate"}
             };
}

- (NSString *) mappingRoot {
    return @"/servers/server";
}
- (NSDictionary *) mapping {
    
    //  keyPath <- xPath
    
    return @{@"name":                       @"name",
             @"stateName":                  @"state",
             @"textDescription":            @"description",
             @"createdAt":                  @"dateTime(created_at,'yyyy/MM/dd HH:mm:ss Z')",
             @"updatedAt":                  @"dateTime(updated_at,'yyyy/MM/dd HH:mm:ss Z')",
             @"resourceReference":          @"links/link[@rel='self']/@href",
             @"deploymentReference":        @"links/link[@rel='deployment']/@href",
             @"currentInstanceReference":   @"links/link[@rel='current_instance']/@href",
             @"nextInstanceReference":      @"links/link[@rel='next_instance']/@href"
             };
}

@end
