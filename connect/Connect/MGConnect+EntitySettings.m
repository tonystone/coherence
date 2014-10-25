//
//  MGConnect+EntitySettings.m
//  MGConnect
//
//  Created by Tony Stone on 4/3/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGConnect+EntitySettings.h"
#import "MGConnect+PrivateSettings.h"
#import "MGConnect+Private.h"
#import <objc/runtime.h>
#import "MGTraceLog.h"

//
// Internal utility functions
//
static NSString * _gsetterStringFromSelector(SEL aSelector);
static NSString * _getterStringFromSelector(SEL aSelector);

//
// NSManagedObjectModel Property Method Functions
//
static NSUInteger  _getModelUnsignedIntegerValue (NSManagedObjectModel * self, SEL _cmd);
static void        _setModelUnsignedIntegerValue (NSManagedObjectModel *  self, SEL _cmd, NSUInteger newValue);
static NSInteger           _getModelIntegerValue (NSManagedObjectModel *  self, SEL _cmd);
static void                _setModelIntegerValue (NSManagedObjectModel *  self, SEL _cmd, NSInteger newValue);
static char                   _getModelCharValue (NSManagedObjectModel *  self, SEL _cmd);
static void                   _setModelCharValue (NSManagedObjectModel *  self, SEL _cmd, char newValue);
static NSObject *           _getModelObjectValue (NSManagedObjectModel *  self, SEL _cmd);
static void                 _setModelObjectValue (NSManagedObjectModel *  self, SEL _cmd, NSObject * newValue);

//
// NSEntityDescription Property Method Functions
//
static NSUInteger _getEntityUnsignedIntegerValue (NSEntityDescription * self, SEL _cmd);
static void       _setEntityUnsignedIntegerValue (NSEntityDescription * self, SEL _cmd, NSUInteger newValue);
static NSInteger          _getEntityIntegerValue (NSEntityDescription * self, SEL _cmd);
static void               _setEntityIntegerValue (NSEntityDescription * self, SEL _cmd, NSInteger newValue);
static char                  _getEntityCharValue (NSEntityDescription * self, SEL _cmd);
static void                  _setEntityCharValue (NSEntityDescription * self, SEL _cmd, char newValue);
static NSObject *          _getEntityObjectValue (NSEntityDescription * self, SEL _cmd);
static void                _setEntityObjectValue (NSEntityDescription * self, SEL _cmd, NSObject * newValue);


@implementation MGConnect (EntitySettings)
@end

@implementation MGSettings

+ (void) initialize {
 
    if (self == [MGSettings class]) {
        
        LogInfo(@"Initializing CoreData Extensions...");
        
        //
        // These protocols contains all the properties
        // that must be added to the modelSettingsInstance and
        // each NSEntityDescription.
        //
        // Query it to get a list of properties to add.
        //

        [self addCoreDataEntityExtensionMethodsForProtocol: @protocol(MGEntitySettings)];
        [self  addCoreDataModelExtensionMethodsForProtocol: @protocol(MGEntitySettings)];

        [self addCoreDataEntityExtensionMethodsForProtocol: @protocol(MGPrivateEntitySettings)];
        [self  addCoreDataModelExtensionMethodsForProtocol: @protocol(MGPrivateModelSettings)];
  
        LogInfo(@"CoreData Extensions initialized");
    }
}

+ (void) addCoreDataModelExtensionMethodsForProtocol: (Protocol *) protocol {
    
    LogInfo(@"Initializing CoreData NSManagedObjectModel Extensions for protocol <%@>...", NSStringFromProtocol(protocol));
    
    unsigned int       propertyCount = 0;
    objc_property_t  * properties = protocol_copyPropertyList( protocol, &propertyCount);
    
    for (int i = 0; i < propertyCount; i++) {
        [self addCoreDataModelExtensionMethodsForProperty: properties[i]];
    }
    free(properties);
    
    LogInfo(@"CoreData NSManagedObjectModel Extensions for protocol <%@> initialized", NSStringFromProtocol(protocol));
}

+ (void) addCoreDataEntityExtensionMethodsForProtocol: (Protocol *) protocol {
    
    LogInfo(@"Initializing CoreData NSEntityDescription Extensions for protocol <%@>...", NSStringFromProtocol(protocol));
    
    unsigned int       propertyCount = 0;
    objc_property_t  * properties = protocol_copyPropertyList( protocol, &propertyCount);
    
    for (int i = 0; i < propertyCount; i++) {
        [self addCoreDataEntityExtensionMethodsForProperty: properties[i]];
    }
    free(properties);
    
    LogInfo(@"CoreData NSEntityDescription Extensions for protocol <%@> initialized", NSStringFromProtocol(protocol));
}

+ (void) addCoreDataModelExtensionMethodsForProperty: (objc_property_t) property {
    
    NSString * propertyName = [NSString stringWithUTF8String: property_getName(property)];
    
    NSString * getterName = propertyName;
    NSString * setterName = _gsetterStringFromSelector(NSSelectorFromString(propertyName));
    
    const char propertyType = property_getAttributes(property)[1];
    
    IMP modelGetterImplementaiton = nil;
    IMP modelSetterImplementation = nil;
    
    switch (propertyType) {
        case 'B':
        case 'c':   // char (includes BOOL since it is a signed char
        {
            modelGetterImplementaiton = (IMP) _getModelCharValue;
            modelSetterImplementation = (IMP) _setModelCharValue;
            break;
        }
        case 'i':   // NSInteger
        case 'l':   // NSInteger (Mac OS)
        case 'q':   // NSInteger (64 bit Mac OS)
        {
            modelGetterImplementaiton = (IMP) _getModelIntegerValue;
            modelSetterImplementation = (IMP) _setModelIntegerValue;
            break;
        }
        case 'I':   // NSUInteger
        case 'L':   // NSUInteger (Mac OS)
        case 'Q':   // NSUInteger (64 bit Mac OS)
        {
            modelGetterImplementaiton = (IMP) _getModelUnsignedIntegerValue;
            modelSetterImplementation = (IMP) _setModelUnsignedIntegerValue;
            break;
        }
        case '@':   // NSObject * or id
        {
            modelGetterImplementaiton = (IMP) _getModelObjectValue;
            modelSetterImplementation = (IMP) _setModelObjectValue;
            break;
        }
        default:
        {
            @throw [MGInitializationException exceptionWithName: @"Initialization Exception" reason: [NSString stringWithFormat: @"Property %@ has type of '%c' which is unrecognized by the system.", propertyName, propertyType] userInfo: nil];
            break;
        }
    }
    
    //
    // We need to build the setter and getter types string
    // so that we can add the method to the class
    //
    // The ? marks get replaced with the property type char
    //
    char getterTypes[4] = "?@:";  getterTypes[0] = propertyType;
    char setterTypes[5] = "v@:?"; setterTypes[3] = propertyType;
    
    //
    // Add the setter and getter to
    // the NSManagedObjectModel class
    //
    class_addMethod([NSManagedObjectModel class], NSSelectorFromString(getterName), modelGetterImplementaiton, getterTypes);
    LogTrace(1, @"Added method implementation to %@: [%@ %s]", NSStringFromClass([NSManagedObjectModel class]), getterName, getterTypes);
    
    class_addMethod([NSManagedObjectModel class], NSSelectorFromString(setterName), modelSetterImplementation, setterTypes);
    LogTrace(1, @"Added method implementation to %@: [%@ %s]", NSStringFromClass([NSManagedObjectModel class]), setterName, setterTypes);

}

+ (void) addCoreDataEntityExtensionMethodsForProperty: (objc_property_t) property {
    
    NSString * propertyName = [NSString stringWithUTF8String: property_getName(property)];
    
    NSString * getterName = propertyName;
    NSString * setterName = _gsetterStringFromSelector(NSSelectorFromString(propertyName));
    
    const char propertyType = property_getAttributes(property)[1];
    
    IMP entityGetterImplementaiton = nil;
    IMP entitySetterImplementation = nil;
    
    switch (propertyType) {
        case 'B':
        case 'c':   // char (includes BOOL since it is a signed char
        {
            entityGetterImplementaiton = (IMP) _getEntityCharValue;
            entitySetterImplementation = (IMP) _setEntityCharValue;
            break;
        }
        case 'i':   // NSInteger
        case 'l':   // NSInteger (Mac OS)
        case 'q':   // NSInteger (64 bit Mac OS)
        {
            entityGetterImplementaiton = (IMP) _getEntityIntegerValue;
            entitySetterImplementation = (IMP) _setEntityIntegerValue;
            break;
        }
        case 'I':   // NSUInteger
        case 'L':   // NSUInteger (Mac OS)
        case 'Q':   // NSUInteger (64 bit Mac OS)
        {
            entityGetterImplementaiton = (IMP) _getEntityUnsignedIntegerValue;
            entitySetterImplementation = (IMP) _setEntityUnsignedIntegerValue;
            break;
        }
        case '@':   // NSObject * or id
        {
            entityGetterImplementaiton = (IMP) _getEntityObjectValue;
            entitySetterImplementation = (IMP) _setEntityObjectValue;
            break;
        }
        default:
        {
            @throw [MGInitializationException exceptionWithName: @"Initialization Exception" reason: [NSString stringWithFormat: @"Property %@ has type of '%c' which is unrecognized by the system.", propertyName, propertyType] userInfo: nil];
            break;
        }
    }
    
    //
    // We need to build the setter and getter types string
    // so that we can add the method to the class
    //
    // The ? marks get replaced with the property type char
    //
    char getterTypes[4] = "?@:";  getterTypes[0] = propertyType;
    char setterTypes[5] = "v@:?"; setterTypes[3] = propertyType;
    
    //
    // Now to the NSEntityDescription class
    //
    class_addMethod([NSEntityDescription class], NSSelectorFromString(getterName), entityGetterImplementaiton, getterTypes);
    LogTrace(1, @"Added method implementation to %@:  [%@ %s]", NSStringFromClass([NSEntityDescription class]), getterName, getterTypes);
    
    class_addMethod([NSEntityDescription class], NSSelectorFromString(setterName), entitySetterImplementation, setterTypes);
    LogTrace(1, @"Added method implementation to %@:  [%@ %s]", NSStringFromClass([NSEntityDescription class]), setterName, setterTypes);
}

- (id) init {
    
    if ((self = [super init])) {
        modelSettings  = [[NSMutableDictionary alloc] init];
        entitySettings = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void) loadFromManagedObjectModel: (NSManagedObjectModel *) aManagedObjectModel {
    
    LogInfo(@"Setting model default values...");
    
    [aManagedObjectModel setStalenessInterval: 60];
    [aManagedObjectModel   setLogTransactions: YES];
    //
    // NOTE: there is no default value for this at the model level
    //[aManagedObjectModel  setWebLinkClassName: @"<:entity>ResourceWebLink"];
    
    LogInfo(@"Model default values set");
    
    //
    // Create a mutable dictionary for each entity to store
    // the entities property values
    //
    for (NSEntityDescription * anEntity in [aManagedObjectModel entities]) {
        [entitySettings setObject: [[NSMutableDictionary alloc] init] forKey: [anEntity name]];
        
        [self loadEntitySettings: anEntity];
    }
}

- (void) loadEntitySettings: (NSEntityDescription *) anEntity {
    
    LogInfo(@"Loading model settings for entity \"%@\"...", [anEntity name]);
    
    //
    // The MGEntitySettings protocol contains all the properties
    // that must be added to the modelSettingsInstance and
    // each NSEntityDescription.
    //
    // Query it to get a list of properties to add.
    //
    unsigned int       propertyCount = 0;
    objc_property_t  * properties = protocol_copyPropertyList( @protocol(MGEntitySettings), &propertyCount);
    
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

- (BOOL) loadValuesForProperty: (objc_property_t) property entityDescription: (NSEntityDescription *) anEntity {
    
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
            case 'B':
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

- (void) validateProperty: (objc_property_t) property valueClass: (Class) aValueClass {
    
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

#pragma mark - NSManagedObjectModel Settings Utility Methods

static NSString * _gsetterStringFromSelector(SEL aSelector) {
    NSString * tmp = NSStringFromSelector(aSelector);
    
    NSString * upperCaseFirstLetter = [[tmp substringWithRange: NSMakeRange(0, 1)] uppercaseString];
    
    return [NSString stringWithFormat: @"set%@%@:", upperCaseFirstLetter, [tmp substringWithRange: NSMakeRange(1, [tmp length] - 1)]];
}

static NSString * _getterStringFromSelector(SEL aSelector) {
    NSString * tmp = NSStringFromSelector(aSelector);
    
    if ([tmp characterAtIndex: [tmp length] - 1] != ':') {
        // We assume this is not a setter
        return tmp;
    } else {
        // We assume this is a setter and we convert it to the normalized name
        NSString * lowerCaseFirstLetter = [[tmp substringWithRange: NSMakeRange(3, 1)] lowercaseString];
        
        return [lowerCaseFirstLetter stringByAppendingString: [tmp substringWithRange: NSMakeRange(4, [tmp length] - 5)]];
    }
}

#define kSettingsMethodNotAccessibleFormatString @"Method %@ is not accessible, this NSManagedObjectModel has not been registered with MGConnect. You must register this model before accessing the extended properties"

#pragma mark - NSManagedObjectModel Settings Property Implementations

//
// NSManagedObjectModel Property Method Functions
//

static NSUInteger _getModelUnsignedIntegerValue (NSManagedObjectModel *  self, SEL _cmd) {
    MGSettings * settings = CFDictionaryGetValue(((_ICS *)__mgRMSharedManager->_ics)->settingsByModelPointer, (__bridge const void *)(self));
    
    NSAssert(settings, kSettingsMethodNotAccessibleFormatString, NSStringFromSelector(_cmd));
    
    return [[settings->modelSettings objectForKey: _getterStringFromSelector(_cmd)] integerValue];
}

static void _setModelUnsignedIntegerValue (NSManagedObjectModel *  self, SEL _cmd, NSUInteger newValue) {
    MGSettings * settings = CFDictionaryGetValue(((_ICS *)__mgRMSharedManager->_ics)->settingsByModelPointer, (__bridge const void *)(self));
    
    NSAssert(settings, kSettingsMethodNotAccessibleFormatString, NSStringFromSelector(_cmd));
    
    NSString * key         = _getterStringFromSelector(_cmd);
    NSNumber * storedValue = [settings->modelSettings objectForKey: key];
    
    if (!storedValue || (storedValue && newValue != [storedValue unsignedIntegerValue])) {
        [settings->modelSettings setObject: [NSNumber numberWithUnsignedInteger: newValue] forKey: key];
        
        LogTrace(2, @"<%@: %p> value changed for setting <%@>, new value %u", NSStringFromClass([self class]), self, key, newValue);
    }
}

static NSInteger _getModelIntegerValue (id self, SEL _cmd) {
    MGSettings * settings = CFDictionaryGetValue(((_ICS *)__mgRMSharedManager->_ics)->settingsByModelPointer, (__bridge const void *)(self));
    
    NSAssert(settings, kSettingsMethodNotAccessibleFormatString, NSStringFromSelector(_cmd));
    
    return [[settings->modelSettings objectForKey: _getterStringFromSelector(_cmd)] integerValue];
}

static void _setModelIntegerValue (NSManagedObjectModel *  self, SEL _cmd, NSInteger newValue) {
    MGSettings * settings = CFDictionaryGetValue(((_ICS *)__mgRMSharedManager->_ics)->settingsByModelPointer, (__bridge const void *)(self));
    
    NSAssert(settings, kSettingsMethodNotAccessibleFormatString, NSStringFromSelector(_cmd));
    
    NSString * key         = _getterStringFromSelector(_cmd);
    NSNumber * storedValue = [settings->modelSettings objectForKey: key];
    
    if (!storedValue || (storedValue && newValue != [storedValue integerValue])) {
        [settings->modelSettings setObject: [NSNumber numberWithInteger: newValue] forKey: key];
        
        LogTrace(2, @"<%@: %p> value changed for setting <%@>, new value %u", NSStringFromClass([self class]), self, key, newValue);
    }
}

static char _getModelCharValue (NSManagedObjectModel *  self, SEL _cmd) {
    MGSettings * settings = CFDictionaryGetValue(((_ICS *)__mgRMSharedManager->_ics)->settingsByModelPointer, (__bridge const void *)(self));
    
    NSAssert(settings, kSettingsMethodNotAccessibleFormatString, NSStringFromSelector(_cmd));
    
    return [[settings->modelSettings objectForKey: _getterStringFromSelector(_cmd)] charValue];
}

static void _setModelCharValue (NSManagedObjectModel *  self, SEL _cmd, char newValue) {
    MGSettings * settings = CFDictionaryGetValue(((_ICS *)__mgRMSharedManager->_ics)->settingsByModelPointer, (__bridge const void *)(self));
    
    NSAssert(settings, kSettingsMethodNotAccessibleFormatString, NSStringFromSelector(_cmd), self);
    
    NSString * key         = _getterStringFromSelector(_cmd);
    NSNumber * storedValue = [settings->modelSettings objectForKey: key];
    
    if (!storedValue || (storedValue && newValue != [storedValue charValue])) {
        [settings->modelSettings setObject: [NSNumber numberWithChar: newValue] forKey: key];
        
        LogTrace(2, @"<%@: %p> value changed for setting <%@>, new value %@", NSStringFromClass([self class]), self, key, newValue ? @"YES" : @"NO");
    }
}

static NSObject * _getModelObjectValue (NSManagedObjectModel *  self, SEL _cmd) {
    MGSettings * settings = CFDictionaryGetValue(((_ICS *)__mgRMSharedManager->_ics)->settingsByModelPointer, (__bridge const void *)(self));
    
    NSAssert(settings, kSettingsMethodNotAccessibleFormatString, NSStringFromSelector(_cmd));
    
    return [settings->modelSettings objectForKey: _getterStringFromSelector(_cmd)];
}

static void _setModelObjectValue (NSManagedObjectModel *  self, SEL _cmd, NSObject * newValue) {
    MGSettings * settings = CFDictionaryGetValue(((_ICS *)__mgRMSharedManager->_ics)->settingsByModelPointer, (__bridge const void *)(self));
    
    NSAssert(settings, kSettingsMethodNotAccessibleFormatString, NSStringFromSelector(_cmd));
    
    NSString * key         = _getterStringFromSelector(_cmd);
    NSObject * storedValue = [settings->modelSettings objectForKey: key];
    
    if (!storedValue || (storedValue && ![newValue isEqual: storedValue])) {
        [settings->modelSettings setObject: newValue forKey: key];
        
        LogTrace(2, @"<%@: %p> value changed for setting <%@>, new value %@", NSStringFromClass([self class]), self, key, newValue);
    }
}

#pragma mark - NSEntityDescription Settings Property Implementations

//
// NSEntityDescription Property Method Functions
//
static NSUInteger _getEntityUnsignedIntegerValue (NSEntityDescription * self, SEL _cmd) {
    MGSettings * settings = CFDictionaryGetValue(((_ICS *)__mgRMSharedManager->_ics)->settingsByModelPointer, (__bridge const void *)([self managedObjectModel]));
    
    NSAssert(settings, kSettingsMethodNotAccessibleFormatString, NSStringFromSelector(_cmd), self);
    
    NSNumber * entityValue = [(NSDictionary *)[settings->entitySettings objectForKey: [self name]] objectForKey: _getterStringFromSelector(_cmd)];
    if (!entityValue) {
        return [[settings->modelSettings objectForKey: _getterStringFromSelector(_cmd)] unsignedIntegerValue];
    }
    return [entityValue unsignedIntegerValue];
}

static void _setEntityUnsignedIntegerValue (NSEntityDescription * self, SEL _cmd, NSUInteger newValue) {
    MGSettings * settings = CFDictionaryGetValue(((_ICS *)__mgRMSharedManager->_ics)->settingsByModelPointer, (__bridge const void *)([self managedObjectModel]));
    
    NSAssert(settings, kSettingsMethodNotAccessibleFormatString, NSStringFromSelector(_cmd), self);
    
    NSString * key                        = _getterStringFromSelector(_cmd);
    NSMutableDictionary * entitySettings  = [settings->entitySettings objectForKey: [self name]];
    NSNumber * storedValue                = [entitySettings objectForKey: key];
    
    if (!storedValue || (storedValue && newValue != [storedValue unsignedIntegerValue])) {
        [entitySettings setObject: [NSNumber numberWithUnsignedInteger: newValue] forKey: key];
        
        LogTrace(2, @"Entity \"%@\" setting <%@> changed, new value %u", [self name], key, newValue);
    }
}

static NSInteger _getEntityIntegerValue (NSEntityDescription * self, SEL _cmd) {
    MGSettings * settings = CFDictionaryGetValue(((_ICS *)__mgRMSharedManager->_ics)->settingsByModelPointer, (__bridge const void *)([self managedObjectModel]));
    
    NSAssert(settings, kSettingsMethodNotAccessibleFormatString, NSStringFromSelector(_cmd), self);
    
    NSNumber * entityValue = [(NSDictionary *)[settings->entitySettings objectForKey: [self name]] objectForKey: _getterStringFromSelector(_cmd)];
    if (!entityValue) {
        return [[settings->modelSettings objectForKey: _getterStringFromSelector(_cmd)] integerValue];
    }
    return [entityValue integerValue];
}

static void _setEntityIntegerValue (NSEntityDescription * self, SEL _cmd, NSInteger newValue) {
    MGSettings * settings = CFDictionaryGetValue(((_ICS *)__mgRMSharedManager->_ics)->settingsByModelPointer, (__bridge const void *)([self managedObjectModel]));
    
    NSAssert(settings, kSettingsMethodNotAccessibleFormatString, NSStringFromSelector(_cmd), self);
    
    NSString * key                        = _getterStringFromSelector(_cmd);
    NSMutableDictionary * entitySettings  = [settings->entitySettings objectForKey: [self name]];
    NSNumber * storedValue                = [entitySettings objectForKey: key];
    
    if (!storedValue || (storedValue && newValue != [storedValue integerValue])) {
        [entitySettings setObject: [NSNumber numberWithInteger: newValue] forKey: key];
        
        LogTrace(2, @"Entity \"%@\" setting <%@> changed, new value %u", [self name], key, newValue);
    }
}

static char _getEntityCharValue (NSEntityDescription * self, SEL _cmd) {
    MGSettings * settings = CFDictionaryGetValue(((_ICS *)__mgRMSharedManager->_ics)->settingsByModelPointer, (__bridge const void *)([self managedObjectModel]));
    
    NSAssert(settings, kSettingsMethodNotAccessibleFormatString, NSStringFromSelector(_cmd), self);
    
    NSNumber * entityValue = [(NSDictionary *)[settings->entitySettings objectForKey: [self name]] objectForKey: _getterStringFromSelector(_cmd)];
    if (!entityValue) {
        return [[settings->modelSettings objectForKey: _getterStringFromSelector(_cmd)] charValue];
    }
    return [entityValue charValue];
}

static void _setEntityCharValue (NSEntityDescription * self, SEL _cmd, char newValue) {
    MGSettings * settings = CFDictionaryGetValue(((_ICS *)__mgRMSharedManager->_ics)->settingsByModelPointer, (__bridge const void *)([self managedObjectModel]));
    
    NSAssert(settings, kSettingsMethodNotAccessibleFormatString, NSStringFromSelector(_cmd), self);
    
    NSString * key                        = _getterStringFromSelector(_cmd);
    NSMutableDictionary * entitySettings  = [settings->entitySettings objectForKey: [self name]];
    NSNumber * storedValue                = [entitySettings objectForKey: key];
    
    if (!storedValue || (storedValue && newValue != [storedValue charValue])) {
        [entitySettings setObject: [NSNumber numberWithChar: newValue] forKey: key];
        
        LogTrace(2, @"Entity \"%@\" setting <%@> changed, new value %@", [self name], key, newValue ? @"YES" : @"NO");
    }
}

static NSObject * _getEntityObjectValue (NSEntityDescription * self, SEL _cmd) {
    MGSettings * settings = CFDictionaryGetValue(((_ICS *)__mgRMSharedManager->_ics)->settingsByModelPointer, (__bridge const void *)([self managedObjectModel]));
    
    NSAssert(settings, kSettingsMethodNotAccessibleFormatString, NSStringFromSelector(_cmd), self);
    
    NSObject * entityValue = [(NSDictionary *)[settings->entitySettings objectForKey: [self name]] objectForKey: _getterStringFromSelector(_cmd)];
    if (!entityValue) {
        return [settings->modelSettings objectForKey: _getterStringFromSelector(_cmd)];
    }
    return entityValue;
}

static void _setEntityObjectValue (NSEntityDescription * self, SEL _cmd, NSObject * newValue) {
    MGSettings * settings = CFDictionaryGetValue(((_ICS *)__mgRMSharedManager->_ics)->settingsByModelPointer, (__bridge const void *)([self managedObjectModel]));
    
    NSAssert(settings, kSettingsMethodNotAccessibleFormatString, NSStringFromSelector(_cmd), self);
    
    NSString * key                        = _getterStringFromSelector(_cmd);
    NSMutableDictionary * entitySettings  = [settings->entitySettings objectForKey: [self name]];
    NSObject * storedValue                = [entitySettings objectForKey: key];
    
    if (!storedValue || (storedValue && ![newValue isEqual: storedValue])) {
        [entitySettings setObject: newValue forKey: key];
        
        LogTrace(2, @"Entity \"%@\" setting <%@> changed, new value %@", [self name], key, newValue);
    }
}

