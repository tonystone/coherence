//
//  MGConnect+Private.h
//  MGConnect
//
//  Created by Tony Stone on 3/28/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGConnect.h"
#import <CoreData/CoreData.h>
#import "MGConnect+EntitySettings.h"

//
// Internal Core Structure
//
typedef struct {
    
    CFMutableDictionaryRef settingsByModelPointer;
    CFMutableDictionaryRef dataStoreManagersByModelPointer;
    CFMutableDictionaryRef dataStoreManagersByName;
    
    BOOL active;
    BOOL online;
} _ICS;

extern NSString * const MGDefaultDataStoreName;
extern MGConnect * __mgRMSharedManager;

@interface MGConnect ()

@end

//
// Internal Structure Class
//
@interface MGSettings : NSObject {
@package
    NSMutableDictionary * modelSettings;
    NSMutableDictionary * entitySettings;
}
- (void) loadFromManagedObjectModel: (NSManagedObjectModel *) aManagedObjectModel;
@end