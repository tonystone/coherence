//
//  MGEntitySettings.m
//  Connect
//
//  Created by Tony Stone on 5/18/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGEntitySettings.h"

#import "MGInitializationException.h"
#import "MGTraceLog.h"

#import <objc/runtime.h>

@implementation MGEntitySettings

+ (void) loadFromManagedObjectModel: (NSManagedObjectModel *) aManagedObjectModel {
    //
    // Create a mutable dictionary for each entity to store
    // the entities property values
    //
    for (NSEntityDescription * anEntity in [aManagedObjectModel entities]) {
        
        [self loadEntitySettings: anEntity];
    }
}

+ (void) loadEntitySettings: (NSEntityDescription *) anEntity {
    
    LogInfo(@"Loading model settings for entity \"%@\"...", [anEntity name]);
    
    //
    // The MGEntitySettings protocol contains all the properties
    // that must be added to the modelSettingsInstance and
    // each NSEntityDescription.
    //
    // Query it to get a list of properties to add.
    //
    unsigned int       propertyCount = 0;
    objc_property_t  * properties = protocol_copyPropertyList( @protocol(MGConnectEntitySettings), &propertyCount);
    
    int propertiesLoaded = 0;
    
    for (int i = 0; i < propertyCount; i++) {
        if ([self loadValuesForProperty: properties[i] entityDescription: anEntity]) {
            propertiesLoaded++;
        }
    }
    free(properties);
    
    if (propertiesLoaded) {
        LogInfo(@"All settings loaded for entity \"%@\"", [anEntity name]);
    } else {
        LogInfo(@"No settings found for entity \"%@\"", [anEntity name]);
    }
}

+ (BOOL) loadValuesForProperty: (objc_property_t) property entityDescription: (NSEntityDescription *) anEntity {
    
    NSString * propertyName = [NSString stringWithUTF8String: property_getName(property)];
    
    NSString * value = [[anEntity userInfo] objectForKey: propertyName];
    
    if (value) {
        
        const char * propertyType = property_getAttributes(property);
        
        switch (propertyType[1]) {
            case 'i':   // NSInteger (iOS)
            case 'l':   // NSInteger (Mac OS)
            case 'q':   // NSInteger (64 bit Mac OS)
            {
                [anEntity setValue: [NSNumber numberWithChar: [value integerValue]] forKey: propertyName];
                break;
            }
            case 'I':   // NSUInteger (iOS)
            case 'L':   // NSUInteger (Mac OS)
            case 'Q':   // NSUInteger (64 bit Mac OS)
            {
                [anEntity setValue: [NSNumber numberWithChar: [value longLongValue]] forKey: propertyName];
                break;
            }
            case 'c':   // char (includes BOOL since it is a signed char
            {
                [anEntity setValue: [NSNumber numberWithChar: [value isEqualToString: @"YES"] ? YES : NO] forKey: propertyName];
                break;
            }
            case '@':   // NSObject * or id
            {
                //
                // NOTE: In this case we expect the class name to be
                //       the value in the property,  If the class is found
                //       We load it here.
                //
                Class valueClass = NSClassFromString(value);
                
                //
                // Make sure that the class is valid
                //
                [self validateProperty: property valueClass: valueClass];
                
                //
                // Allocate an instance of the class
                //
                id classInstance = [[valueClass alloc] init];
                
                [anEntity setValue: classInstance forKey: propertyName];
                
                break;
            }
            default:
            {
                @throw [MGInitializationException exceptionWithName: @"Initialization Exception" reason: [NSString stringWithFormat: @"Property %@ has type of '%s' which is unrecognized by the system.", propertyName, propertyType] userInfo: nil];
                break;
            }
        }
        return YES;
    }
    
    return NO;
}

+ (void) validateProperty: (objc_property_t) property valueClass: (Class) aValueClass {
    
    if (!aValueClass) {
        @throw [MGInitializationException exceptionWithName: @"Initialization Exception" reason: [NSString stringWithFormat: @"You specified class named \"%@\" for property %s but the class was not found.", NSStringFromClass(aValueClass), property_getName(property)] userInfo: nil];
    }
    
    //
    // Example return value
    //
    // @property (nonatomic, strong) NSObject <MGEntityActionNotificationDelegate,NSCopying> * actionNotificationDelegate;
    //
    // "T@"NSObject<MGEntityActionNotificationDelegate><NSCopying>",&,N"
    //
    // @property (nonatomic, strong) id <MGEntityActionNotificationDelegate,NSCopying> actionNotificationDelegate;
    //
    // T@"<MGEntityActionNotificationDelegate><NSCopying>",&,N
    //
    NSString * propertyAttributeString = [NSString stringWithUTF8String: property_getAttributes(property)];
    
    NSArray * propertyAttributes = [propertyAttributeString componentsSeparatedByString: @","];
    
    NSString * typeEncoding = [propertyAttributes objectAtIndex: 0];
    
    typeEncoding = [typeEncoding stringByReplacingOccurrencesOfString: @"T@" withString: @""];
    typeEncoding = [typeEncoding stringByReplacingOccurrencesOfString: @"\"" withString: @""];
    typeEncoding = [typeEncoding stringByReplacingOccurrencesOfString: @">"  withString: @""];
    
    NSArray * types = [typeEncoding componentsSeparatedByString: @"<"];
    
    //
    // If it does not starts with a protocol <, we need to get the type
    // and validate it.
    //
    if (![typeEncoding hasPrefix: @"<"]) {
        NSString * className = [types objectAtIndex: 0];
        
        Class propertyClass = NSClassFromString(className);
        if (!(aValueClass == propertyClass || [aValueClass isSubclassOfClass: propertyClass])) {
            
            @throw [MGInitializationException exceptionWithName: @"Initialization Exception" reason: [NSString stringWithFormat: @"You specified class named \"%@\" for property %s but the class is not of the correct type.  It must be an instance of or a subclass of %@ .", NSStringFromClass(aValueClass), property_getName(property), className] userInfo: nil];
        }
        // String the class type
        types = [types subarrayWithRange: NSMakeRange(1, [types count]-1)];
    }
    
    for (NSString * protocolString in types) {
        Protocol * propertyProtocol =  NSProtocolFromString(protocolString);
        
        if (![aValueClass conformsToProtocol: propertyProtocol]) {
            @throw [MGInitializationException exceptionWithName: @"Initialization Exception" reason: [NSString stringWithFormat: @"You specified class named \"%@\" for property %s but the class does not conform to the required protocol %@.", NSStringFromClass(aValueClass), property_getName(property), protocolString] userInfo: nil];
        }
    }
}

@end
