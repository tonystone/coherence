//
//  MGConnectInitializationOptions.m
//  Connect
//
//  Created by Tony Stone on 5/9/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGConnectInitializationOptions.h"
#import "MGInitializationException.h"

#import "MGTraceLog.h"

NSString * const MGConnectTakeOverCoreDataOption                       = @"MGConnectTakeOverCoreDataOption";
NSString * const MGConnectAutoLocateEntityActionDefinitionsOption      = @"MGConnectAutoLocateEntityActionDefinitionsOption";
NSString * const MGConnectEntityActionDefinitionTemplateOption         = @"MGConnectEntityActionDefinitionTemplateOption";
NSString * const MGConnectMainThreadManagedObjectContextLimitOption    = @"MGConnectMainThreadManagedObjectContextLimitOption";

@implementation MGConnectInitializationOptions

static NSMutableDictionary * options;

+ (void) initialize {
    
    //
    // Create a set of default options with all
    // possible keys and merge the users options
    // with those
    //
    if (self == [MGConnectInitializationOptions class]) {
        options = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                        @YES,                        MGConnectTakeOverCoreDataOption,
                        @YES,                        MGConnectAutoLocateEntityActionDefinitionsOption,
                         @"<entity>EntityActionDefinition", MGConnectEntityActionDefinitionTemplateOption,
                        @1,                          MGConnectMainThreadManagedObjectContextLimitOption,
                        nil];
        
        LogTrace(1, @"default initialization options: %@", options);
    }
}

+ (void) overrideOptions:(NSDictionary *) overrideOptions {
    
    NSParameterAssert(overrideOptions != nil);
    
    LogTrace(1, @"Overriding initialization options: %@", overrideOptions);

    [options setValuesForKeysWithDictionary: overrideOptions];
}

+ (NSDictionary *) initializationOptions: (NSDictionary *) optionsAndTypes {
    
    NSMutableDictionary * requestedOptions = [[NSMutableDictionary alloc] initWithCapacity: [optionsAndTypes count]];
    
    for (NSString * option in [optionsAndTypes allKeys]) {
        Class type = [optionsAndTypes objectForKey: option];
        
        id value = [options objectForKey: option];
        
        if (!value) {
            @throw [MGInitializationException exceptionWithName: @"Initialization Exception" reason: [NSString stringWithFormat: @"Required option %@ is missing, can not initialize without it", option] userInfo: nil];
        }
        
        if (![value isKindOfClass: type]) {
            @throw [MGInitializationException exceptionWithName: @"Initialization Exception" reason: [NSString stringWithFormat: @"%@ must be of type %@", MGConnectAutoLocateEntityActionDefinitionsOption, NSStringFromClass([NSNumber class])] userInfo: nil];
        }
        
        [requestedOptions setObject: value forKey: option];
    }
    
    LogTrace(2, @"Using options: %@", requestedOptions);
    
    return requestedOptions;
}

@end
