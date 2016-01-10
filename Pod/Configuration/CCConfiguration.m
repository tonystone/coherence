/**
 *   CCConfiguration.m
 *
 *   Copyright 2015 The Climate Corporation
 *   Copyright 2015 Tony Stone
 *
 *   Licensed under the Apache License, Version 2.0 (the "License");
 *   you may not use this file except in compliance with the License.
 *   You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 *   Unless required by applicable law or agreed to in writing, software
 *   distributed under the License is distributed on an "AS IS" BASIS,
 *   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *   See the License for the specific language governing permissions and
 *   limitations under the License.
 *
 *   Created by Tony Stone on 6/22/15.
 */
#import "CCConfiguration.h"
#import "CCObject.h"
#import <objc/runtime.h>
#import <TraceLog/TraceLog.h>


static NSString * const CCErrorDomain      = @"FSErrorDomain";
static NSString * const CCDefaultBundleKey = @"TCCConfiguration";

typedef enum {
    CCInitializationErrorCode   = 100,
    CCMissingConfigurationKey   = 101,
    CCInvalidConfigurationKeyType = 102,
} CCErrorDomainCode;

@implementation CCConfiguration {
        Protocol __weak * conformingProtocol;
    }

    + (NSDictionary *) defaults {
        return @{};
    }

    + (NSString *) bundleKey {
        return CCDefaultBundleKey;
    }

    + (id)configurationForProtocol:(Protocol *)aProtocol {
        
        Class implClass = [CCObject classForProtocol: aProtocol baseClass: self];

        CCConfiguration * config = (CCConfiguration *) [[implClass alloc] init];

        config->conformingProtocol = aProtocol;

        [self loadObject: config protocol: aProtocol bundle: [NSBundle mainBundle] bundleKey: [self bundleKey] defaults: [self defaults]];

        return config;
    }

    + (id)configurationForProtocol:(Protocol *)aProtocol defaults:(NSDictionary *)defaults {

        Class implClass = [CCObject classForProtocol: aProtocol baseClass: self];

        CCConfiguration * config = (CCConfiguration *) [[implClass alloc] init];

        config->conformingProtocol = aProtocol;

        [self loadObject: config protocol: aProtocol bundle: [NSBundle mainBundle] bundleKey: [self bundleKey] defaults:defaults];

        return config;
    }

    + (void)loadObject: (NSObject *) anObject protocol: (Protocol *) conformingProtocol bundle:(NSBundle *)bundle bundleKey: (NSString *) bundleKey defaults:(NSDictionary *)defaults {

        NSMutableArray * errors = [[NSMutableArray alloc] init];

        if (![[NSBundle mainBundle] infoDictionary][bundleKey]) {
            [errors addObject: [NSError errorWithDomain: CCErrorDomain code: CCMissingConfigurationKey userInfo: @{NSLocalizedDescriptionKey: [NSString stringWithFormat: @"Required bundle key %@ missing form Info.plist file", bundleKey]}]];
        }

        [self loadObject: anObject dictionary: [[NSBundle mainBundle] infoDictionary][bundleKey] defaults:defaults forProtocol: conformingProtocol errors:errors];

        if ([errors count] > 0) {
            NSMutableString * reasonMessage = [[NSMutableString alloc] initWithFormat: @"The Following error(s) occured during initialization of %@\n\n", NSStringFromClass([self class])];

            for (NSError * error in errors) {
                [reasonMessage appendFormat: @"\t%@\n", [error localizedDescription]];
            }
            @throw [NSException exceptionWithName: @"Initialization Exception" reason: reasonMessage userInfo: nil];
        }
    }

    + (void)loadObject: (NSObject *) anObject dictionary:(NSDictionary *)values defaults:(NSDictionary *)defaults forProtocol:(Protocol *)aProtocol errors:(NSMutableArray *)errors {
        
        NSString * errorMessage = nil;
        CCErrorDomainCode errorCode = CCInitializationErrorCode;

        unsigned int       propertyCount = 0;
        objc_property_t  * properties = protocol_copyPropertyList(aProtocol, &propertyCount);
        
        for (int i = 0; i < propertyCount; i++) {
            NSString * propertyName = [NSString stringWithCString: property_getName(properties[i]) encoding: NSUTF8StringEncoding];

            id value = values[propertyName];
            
            if (!value) {
                value = defaults[propertyName];
            }
            
            if (value) {
                [anObject setValue: value forKey: propertyName];
            } else {
                errorMessage = [NSString stringWithFormat:@"%@ key was missing from the info.plist and no default value was supplied, this value is required.", propertyName];
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
