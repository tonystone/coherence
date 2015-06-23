//
// Created by Tony Stone on 6/22/15.
//

#import "CCConfiguration.h"
#import <objc/runtime.h>
#import <TraceLog/TraceLog.h>
#import "NSString+CapitalizeFirstLetter.h"

static NSString * const CCErrorDomain = @"FSErrorDomain";

typedef enum {
    CCInitializationErrorCode   = 100,
    CCMissingConfigurationKey   = 101,
    CCInvalidConfigurationKeyType = 102,
} CCErrorDomainCode;

@interface CCConfiguration (ClassCreation)
    + (Class) classForProtocol: (Protocol *) aProtocol;
@end

@implementation CCConfiguration {
        Protocol __weak * conformingProtocol;
    }

    + (id)configurationForProtocol:(Protocol *)aProtocol {
        
        Class implClass = [self classForProtocol: aProtocol];

        CCConfiguration * config = (CCConfiguration *) [[implClass alloc] init];

        config->conformingProtocol = aProtocol;

        NSDictionary * defaults = nil;
        if ([config respondsToSelector: @selector(defaults)]) {
            defaults = [config defaults];
        }

        [config loadFromDictionary:[[NSBundle mainBundle] infoDictionary] capitalizeFirstLetter:YES keyPrefix: @"TCC" defaults: defaults];

        return config;
    }

    + (id)configurationForProtocol:(Protocol *)aProtocol defaults:(NSDictionary *)defaults {

        Class implClass = [self classForProtocol: aProtocol];

        CCConfiguration * config = (CCConfiguration *) [[implClass alloc] init];

        config->conformingProtocol = aProtocol;

        [config loadFromDictionary:[[NSBundle mainBundle] infoDictionary] capitalizeFirstLetter:YES keyPrefix: @"TCC" defaults: defaults];

        return config;
    }

    - (void) loadFromDictionary: (NSDictionary *)values capitalizeFirstLetter: (BOOL) capitalize keyPrefix: (NSString *) keyPrefix defaults: (NSDictionary *) defaults  {

        NSMutableArray * errors = [[NSMutableArray alloc] init];

        [self loadFromDictionary: values capitalizeFirstLetter: capitalize keyPrefix: keyPrefix defaults: defaults forProtocol: conformingProtocol errors: errors];
        
        unsigned int protocolCount = 0;
        Protocol * __unsafe_unretained * protocolList = protocol_copyProtocolList(conformingProtocol, &protocolCount);
        
        for (int p = 0; p < protocolCount; p++) {
            [self loadFromDictionary: values capitalizeFirstLetter: capitalize keyPrefix: keyPrefix defaults: defaults forProtocol: protocolList[p] errors: errors];

        }
        free(protocolList);

        if ([errors count] > 0) {
            NSMutableString * reasonMessage = [[NSMutableString alloc] initWithFormat: @"The Following error(s) occured during initialization of %@\n\n", NSStringFromClass([self class])];

            for (NSError * error in errors) {
                [reasonMessage appendFormat: @"\t%@\n", [error localizedDescription]];
            }
            @throw [NSException exceptionWithName: @"Initialization Exception" reason: reasonMessage userInfo: nil];
        }
    }

    - (void) loadFromDictionary: (NSDictionary *)values capitalizeFirstLetter: (BOOL) capitalize keyPrefix: (NSString *) keyPrefix defaults: (NSDictionary *) defaults forProtocol: (Protocol *) aProtocol errors: (NSMutableArray *) errors {
        
        NSString * errorMessage = nil;
        CCErrorDomainCode errorCode = CCInitializationErrorCode;

        unsigned int       propertyCount = 0;
        objc_property_t  * properties = protocol_copyPropertyList(aProtocol, &propertyCount);
        
        for (int i = 0; i < propertyCount; i++) {
            NSString * propertyName      = [NSString stringWithCString: property_getName(properties[i]) encoding: NSUTF8StringEncoding];
            NSString * dictionaryKeyName = [propertyName copy];
            
            if (keyPrefix || capitalize) {
                dictionaryKeyName = [dictionaryKeyName stringWithCapitalizedFirstLetter];
            }
            if (keyPrefix) {
                dictionaryKeyName = [keyPrefix stringByAppendingString: dictionaryKeyName];
            }
            
            id value = values[dictionaryKeyName];
            
            if (!value) {
                value = defaults[propertyName];
            }
            
            if (value) {
                [self setValue: value forKey: propertyName];
            } else {
                errorMessage = [NSString stringWithFormat:@"%@ key was missing from the info.plist and no default value was supplied, this value is required.", dictionaryKeyName];
                errorCode    = CCMissingConfigurationKey;
            }
            if (errorMessage) {
                [errors addObject: [NSError errorWithDomain: CCErrorDomain code: errorCode userInfo: @{NSLocalizedDescriptionKey: errorMessage}]];
                errorMessage = nil;
            }
        }
        free(properties);
    }

@end

//
// Forward declarations
//
static SEL setterSelectorFromPropertyName(const char * nameCStr);
static SEL getterSelectorFromPropertyName(const char * nameCStr);

@interface CCPropertyAttributes : NSObject {
    @public
        NSString * name;
        char       type;
        NSString * ivarName;
        NSUInteger ivarSize;
        NSUInteger ivarAlignment;

        SEL        getter;
        SEL        setter;

        struct {
            unsigned int readonly:1;
            unsigned int nonatomic:1;
            unsigned int copy:1;
            unsigned int dynamic:1;

            unsigned int reserved:28;
        } flags;
    }
    - (NSString *)description;
@end
@implementation CCPropertyAttributes
    - (NSString *)description {
        NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
        [description appendFormat:@"\n\tname=%@", name];
        [description appendFormat:@"\n\ttype=%c", type];
        [description appendFormat:@"\n\tivarName=%@", ivarName];
        [description appendFormat:@"\n\tivarSize=%lu", (unsigned long)ivarSize];
        [description appendFormat:@"\n\tivarAlignment=%lu", (unsigned long)ivarAlignment];
        [description appendFormat:@"\n\tgetter=%@", NSStringFromSelector(getter)];
        [description appendFormat:@"\n\tsetter=%@", NSStringFromSelector(setter)];
        [description appendString:@"\n>"];
        return description;
    }
@end

//
// Class Creation methods
//
@implementation CCConfiguration (ClassCreation)

    + (Class) classForProtocol: (Protocol *) aProtocol {

        NSString * className = [NSString stringWithFormat: @"%@Impl_", NSStringFromProtocol(aProtocol)];

        Class newClass = NSClassFromString(className);

        if(newClass == nil) {

            LogInfo(@"Creating class \"%@\" for protocol \"%@\" using base class: \"%@\"...", className, NSStringFromProtocol(aProtocol), NSStringFromClass(self));

            // Create the new class
            newClass = objc_allocateClassPair(self, [className UTF8String], 0);

            // Add the protocol specified.
            class_addProtocol(newClass, aProtocol);

            // Add the implementation
            [self addProtocolImplementation: aProtocol toClass: newClass];

            unsigned int protocolCount = 0;
            Protocol * __unsafe_unretained * protocolList = protocol_copyProtocolList(aProtocol, &protocolCount);

            for (int p = 0; p < protocolCount; p++) {
                [self addProtocolImplementation: protocolList[p] toClass: newClass];
            }
            free(protocolList);

            objc_registerClassPair(newClass);

            LogInfo(@"Class \"%@\" created...", className);

        } else {

            NSAssert([newClass superclass] == self, @"Error: You have previously created a configuration for \"%@\" using the base class \"%@\".  You can not redefine the class.  Please use \"%@\" to instantiate your configuration or change your original configuration to use \"%@\".", NSStringFromProtocol(aProtocol), NSStringFromClass([newClass superclass]), NSStringFromClass([newClass superclass]), NSStringFromClass(self));
        }

        return newClass;
    }

    + (void) addProtocolImplementation: (Protocol *) aProtocol toClass: (Class) newClass {

        unsigned int       propertyCount = 0;
        objc_property_t  * properties = protocol_copyPropertyList(aProtocol, &propertyCount);

        for (int i = 0; i < propertyCount; i++) {
            const char * propertyName       = property_getName(properties[i]);
            const char * propertyAttributes = property_getAttributes(properties[i]);

            unsigned int attributeCount = 0;
            objc_property_attribute_t * propertyAttributeList = property_copyAttributeList (properties[i], &attributeCount);

            CCPropertyAttributes * attributes = [[CCPropertyAttributes alloc] init];

            attributes->name = [NSString stringWithUTF8String: propertyName];

            NSGetSizeAndAlignment(propertyAttributes, &attributes->ivarSize, &attributes->ivarAlignment);

            NSArray * attributeComponents = [[NSString stringWithCString: propertyAttributes encoding: NSUTF8StringEncoding] componentsSeparatedByString: @","];

            attributes->type = propertyAttributes[1];

            for (NSString * component in attributeComponents) {
                unichar firstChar = [component characterAtIndex: 0];

                switch (firstChar) {
                    case 'R':   // The property is read-only (readonly).
                        attributes->flags.readonly = TRUE;
                        break;
                    case 'C':   // The property is a copy of the value last assigned (copy).
                        attributes->flags.copy = TRUE;
                        break;
                    case '&':   // The property is a reference to the value last assigned (retain).
                        break;
                    case 'N':   // The property is non-atomic (nonatomic).
                        attributes->flags.nonatomic = TRUE;
                        break;
                    case 'G':   // The property defines a custom getter selector name. The name follows the G (for example, GcustomGetter,).
                        attributes->getter = NSSelectorFromString([component substringFromIndex: 1]);
                        break;
                    case 'S':   // The property defines a custom setter selector name. The name follows the S (for example, ScustomSetter:,).
                        attributes->setter = NSSelectorFromString([component substringFromIndex: 1]);
                        break;
                    case 'D':   // The property is dynamic (@dynamic).
                        attributes->flags.dynamic = TRUE;
                        break;
                    case 'V':   // ivar name
                        attributes->ivarName = [component substringFromIndex: 1];
                        break;
                    case 'W':   // The property is a weak reference (__weak).
                    case 'P':   // The property is eligible for garbage collection.
                    case 't':   // Specifies the type using old-style encoding.
                    default:
                        // We don't care about these.
                        break;
                }
            }

            if (!attributes->ivarName) {
                attributes->ivarName = [NSString stringWithUTF8String: propertyName];
            }
            if (!attributes->getter) {
                attributes->getter = getterSelectorFromPropertyName(propertyName);
            }
            if (!attributes->setter) {
                attributes->setter = setterSelectorFromPropertyName(propertyName);
            }

            LogTrace(1,@"Defining property: %@", attributes);

            if (!class_addIvar(newClass, [attributes->ivarName UTF8String] , attributes->ivarSize, attributes->ivarAlignment, propertyAttributes)) {
                LogError(@"Failed to add ivar %@ for protocol %@ impl.", attributes->ivarName, NSStringFromProtocol(aProtocol));
            }

            if (class_getProperty(newClass, propertyName) == NULL) {

                if (!class_addProperty(newClass, propertyName, propertyAttributeList, attributeCount)) {
                    LogError(@"Failed to add property %s for protocol %@ impl.", propertyName, NSStringFromProtocol(aProtocol));
                }
            }

            char getterAttributes[4]; strcpy(getterAttributes, " @:");  getterAttributes[0] = attributes->type;

            if (!class_addMethod(newClass, attributes->getter, [self getterImp: attributes->ivarName forType: attributes->type], getterAttributes)) {

                if (!class_replaceMethod(newClass, attributes->getter, [self getterImp: attributes->ivarName forType: attributes->type], getterAttributes)) {
                    LogError(@"Failed to add getter method for property %s for protocol %@ impl.", propertyName, NSStringFromProtocol(aProtocol));
                }
            }

            char setterAttributes[5]; strcpy(setterAttributes, "v@: "); setterAttributes[3] = attributes->type;

            if (!class_addMethod(newClass, attributes->setter, [self setterImp:attributes->ivarName forType:attributes->type], setterAttributes)) {

                if (!class_replaceMethod(newClass, attributes->setter, [self setterImp:attributes->ivarName forType:attributes->type], setterAttributes)) {
                    LogError(@"Failed to add setter method for property %s for protocol %@ impl.", propertyName, NSStringFromProtocol(aProtocol));
                }
            }

            free(propertyAttributeList);
        }
        free(properties);
    }

    + (IMP) getterImp: (NSString *) ivarName forType: (const char) type  {

        switch (type) {
            case 'c':   // char

                return imp_implementationWithBlock(
                        ^(id _self) {
                            Ivar ivar = class_getInstanceVariable([_self class], [ivarName UTF8String]);

                            ptrdiff_t offset = ivar_getOffset(ivar);
                            unsigned char * selfBytes = (unsigned char *)(__bridge void *)_self;
                            
                            return *((char *)(selfBytes + offset));
                        }
                );

            case 'B':   //  BOOL and C++ bool or a C99 _Bool (for arm64)

                return imp_implementationWithBlock(
                        ^(id _self) {
                            Ivar ivar = class_getInstanceVariable([_self class], [ivarName UTF8String]);

                            ptrdiff_t offset = ivar_getOffset(ivar);
                            unsigned char * selfBytes = (unsigned char *)(__bridge void *)_self;
                            
                            return *((BOOL *)(selfBytes + offset));
                        }
                );

            case 'i':   // NSInteger
            case 'l':   // NSInteger (Mac OS)
            case 'q':   // NSInteger (64 bit Mac OS)

                return imp_implementationWithBlock(
                        ^(id _self) {
                            Ivar ivar = class_getInstanceVariable([_self class], [ivarName UTF8String]);

                            ptrdiff_t offset = ivar_getOffset(ivar);
                            unsigned char * selfBytes = (unsigned char *)(__bridge void *)_self;
                            
                            return *((NSInteger *)(selfBytes + offset));
                        }
                );

            case 'I':   // NSUInteger
            case 'L':   // NSUInteger (Mac OS)
            case 'Q':   // NSUInteger (64 bit Mac OS)

                return imp_implementationWithBlock(
                        ^(id _self) {
                            Ivar ivar = class_getInstanceVariable([_self class], [ivarName UTF8String]);

                            ptrdiff_t offset = ivar_getOffset(ivar);
                            unsigned char * selfBytes = (unsigned char *)(__bridge void *)_self;
                            
                            return *((NSUInteger *)(selfBytes + offset));
                        }
                );

            case 'f':   // float

                return imp_implementationWithBlock(
                        ^(id _self) {
                            Ivar ivar = class_getInstanceVariable([_self class], [ivarName UTF8String]);

                            ptrdiff_t offset = ivar_getOffset(ivar);
                            unsigned char * selfBytes = (unsigned char *)(__bridge void *)_self;
                            
                            return *((float *)(selfBytes + offset));
                        }
                );

            case 'd':

                return imp_implementationWithBlock(
                        ^(id _self) {
                            Ivar ivar = class_getInstanceVariable([_self class], [ivarName UTF8String]);

                            ptrdiff_t offset = ivar_getOffset(ivar);
                            unsigned char * selfBytes = (unsigned char *)(__bridge void *)_self;
                            
                            return *((double *)(selfBytes + offset));
                        }
                );

            case '@':   // NSObject * or id

                return imp_implementationWithBlock(
                        ^(id _self) {
                            Ivar ivar = class_getInstanceVariable([_self class], [ivarName UTF8String]);

                            return object_getIvar(_self, ivar);
                        }
                );

            default:
                LogTrace(1, @"Type '%c' not supported, can not create Implementation for property %@ .", type, ivarName);

                return NULL;
        }
    }

    + (IMP) setterImp: (NSString *) ivarName forType: (const char) type {

        switch (type) {
            case 'c':   // char

                return imp_implementationWithBlock(
                        ^(id _self, char newValue) {
                            Ivar ivar = class_getInstanceVariable([_self class], [ivarName UTF8String]);

                            ptrdiff_t offset = ivar_getOffset(ivar);
                            unsigned char * selfBytes = (unsigned char *)(__bridge void *)_self;
                            
                            char oldValue = *((char *)(selfBytes + offset));
                            
                            if (oldValue != newValue) {
                                *((char *)(selfBytes + offset)) = newValue;
                            }
                        }
                );

            case 'B':   //  BOOL and C++ bool or a C99 _Bool (for arm64)

                return imp_implementationWithBlock(
                        ^(id _self, BOOL newValue) {
                            Ivar ivar = class_getInstanceVariable([_self class], [ivarName UTF8String]);

                            ptrdiff_t offset = ivar_getOffset(ivar);
                            unsigned char * selfBytes = (unsigned char *)(__bridge void *)_self;
                            
                            BOOL oldValue = *((BOOL *)(selfBytes + offset));
                            
                            if (oldValue != newValue) {
                                *((BOOL *)(selfBytes + offset)) = newValue;
                            }
                        }
                );

            case 'i':   // NSInteger
            case 'l':   // NSInteger (Mac OS)
            case 'q':   // NSInteger (64 bit Mac OS)

                return imp_implementationWithBlock(
                        ^(id _self, NSInteger newValue) {
                            Ivar ivar = class_getInstanceVariable([_self class], [ivarName UTF8String]);

                            ptrdiff_t offset = ivar_getOffset(ivar);
                            unsigned char * selfBytes = (unsigned char *)(__bridge void *)_self;
                            
                            NSInteger oldValue = *((NSInteger *)(selfBytes + offset));
                            
                            if (oldValue != newValue) {
                                *((NSInteger *)(selfBytes + offset)) = newValue;
                            }
                        }
                );

            case 'I':   // NSUInteger
            case 'L':   // NSUInteger (Mac OS)
            case 'Q':   // NSUInteger (64 bit Mac OS)

                return imp_implementationWithBlock(
                        ^(id _self, NSUInteger newValue) {
                            Ivar ivar = class_getInstanceVariable([_self class], [ivarName UTF8String]);

                            ptrdiff_t offset = ivar_getOffset(ivar);
                            unsigned char * selfBytes = (unsigned char *)(__bridge void *)_self;
                            
                            NSUInteger oldValue = *((NSUInteger *)(selfBytes + offset));
                            
                            if (oldValue != newValue) {
                                *((NSUInteger *)(selfBytes + offset)) = newValue;
                            }
                        }
                );

            case 'f':   // float

                return imp_implementationWithBlock(
                        ^(id _self, float newValue) {
                            Ivar ivar = class_getInstanceVariable([_self class], [ivarName UTF8String]);

                            ptrdiff_t offset = ivar_getOffset(ivar);
                            unsigned char * selfBytes = (unsigned char *)(__bridge void *)_self;
                            
                            float oldValue = *((float *)(selfBytes + offset));
                            
                            if (oldValue != newValue) {
                                *((float *)(selfBytes + offset)) = newValue;
                            }
                        }
                );

            case 'd':

                return imp_implementationWithBlock(
                        ^(id _self, double newValue) {
                            Ivar ivar = class_getInstanceVariable([_self class], [ivarName UTF8String]);

                            ptrdiff_t offset = ivar_getOffset(ivar);
                            unsigned char * selfBytes = (unsigned char *)(__bridge void *)_self;
                            
                            double oldValue = *((double *)(selfBytes + offset));
                            
                            if (oldValue != newValue) {
                                *((double *)(selfBytes + offset)) = newValue;
                            }
                        }
                );

            case '@':   // NSObject * or id
                return imp_implementationWithBlock(
                        ^(id _self, id newValue) {
                            Ivar ivar = class_getInstanceVariable([_self class], [ivarName UTF8String]);

                            id oldValue = object_getIvar(_self, ivar);
                            if (![oldValue isEqual: newValue]) {

                                object_setIvar(_self, ivar, newValue);
                            }
                        }
                );
            default:
                LogTrace(1, @"Type '%c' not supported, can not create Implementation for property %@ .", type, ivarName);

                return NULL;
        }
    }

@end

//
// Utility functions
//
static SEL getterSelectorFromPropertyName(const char * nameCStr) {
    NSString * name = [[NSString alloc] initWithCString: nameCStr  encoding: NSUTF8StringEncoding];

    return NSSelectorFromString(name);
}

static SEL setterSelectorFromPropertyName(const char * nameCStr) {
    NSString * name = [[NSString alloc] initWithCString: nameCStr  encoding: NSUTF8StringEncoding];

    NSString * upperCaseFirstLetter = [[name substringWithRange:NSMakeRange(0, 1)] uppercaseString];

    return NSSelectorFromString([NSString stringWithFormat: @"set%@%@:", upperCaseFirstLetter, [name substringWithRange: NSMakeRange(1, [name length] - 1)]]);
}




