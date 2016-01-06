//
//  CCObject.m
//  Pods
//
//  Created by Tony Stone on 12/18/15.
//
//

#import "CCObject.h"
#import <objc/runtime.h>
#import <TraceLog/TraceLog.h>

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
@implementation CCObject

+ (Class) classForProtocol: (Protocol *) aProtocol baseClass: (Class) baseClass {

    @autoreleasepool {
        NSString * className = [NSString stringWithFormat: @"%@Impl_", NSStringFromProtocol(aProtocol)];

        Class newClass = NSClassFromString(className);

        if(newClass == nil) {

            LogInfo(@"Creating class \"%@\" for protocol \"%@\" using base class: \"%@\"...", className, NSStringFromProtocol(aProtocol), NSStringFromClass(baseClass));

            // Create the new class
            newClass = objc_allocateClassPair(baseClass, [className UTF8String], 0);

            // Add the protocol specified.
            class_addProtocol(newClass, aProtocol);

            // Add the implementation
            [self addProtocolImplementation: aProtocol toClass: newClass];

            objc_registerClassPair(newClass);

            LogInfo(@"Class \"%@\" created...", NSStringFromClass(newClass));

        } else {

            NSAssert([newClass superclass] == baseClass, @"Error: You have previously created a class for \"%@\" using the base class \"%@\".  You can not redefine the class.  Please use \"%@\" to instantiate your configuration or change your original configuration to use \"%@\".", NSStringFromProtocol(aProtocol), NSStringFromClass([newClass superclass]), NSStringFromClass([newClass superclass]), NSStringFromClass(baseClass));
        }

        return newClass;
    }
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
        
        LogTrace(4,@"Defining property: %@", attributes);
        
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

#if !__has_feature(objc_arc)
        [attributes release];
#endif
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

                           id value = object_getIvar(_self, ivar);
                           
                           return value;
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

#if !__has_feature(objc_arc)
                           [oldValue release];
                           [newValue retain];
#endif
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

