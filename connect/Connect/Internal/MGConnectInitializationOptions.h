//
//  MGConnectInitializationOptions.h
//  Connect
//
//  Created by Tony Stone on 5/9/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const MGConnectTakeOverCoreDataOption;
extern NSString * const MGConnectAutoLocateEntityActionDefinitionsOption;
extern NSString * const MGConnectEntityActionDefinitionTemplateOption;
extern NSString * const MGConnectMainThreadManagedObjectContextLimitOption;

@interface MGConnectInitializationOptions : NSObject

+ (void) overrideOptions: (NSDictionary *) overrideOptions;
+ (NSDictionary *) initializationOptions: (NSDictionary *) keysAndTypes;

@end
