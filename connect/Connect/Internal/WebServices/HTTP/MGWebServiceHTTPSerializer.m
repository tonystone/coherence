//
//  MGWebServiceHTTPSerializer.m
//  MGResourceManager
//
//  Created by Tony Stone on 4/14/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGWebServiceHTTPSerializer.h"
#import "MGWebServiceInMessage.h"
#import "MGInitializationException.h"
#import "MGRuntimeException.h"
#import "MGWSDL.h"

@implementation MGWebServiceHTTPSerializer {
    NSDictionary * locationReplacementAttributes;
}

- (NSURL *) serializedURLForMethod: (MGWSDLHTTPExtensionMethod) aMethod inMessage: (MGWebServiceInMessage *) inMessage {
    [self doesNotRecognizeSelector: _cmd];
    return nil;
}

- (NSData *) serializedMessageBodyForMethod: (MGWSDLHTTPExtensionMethod) aMethod inMessage: (MGWebServiceInMessage *) inMessage {
    [self doesNotRecognizeSelector: _cmd];
    return nil;
}

@end

@implementation MGWebServiceHTTPSerializer (SubclassHelperMethods)

- (NSMutableString *) tokenizedIRI: (MGWebServiceInMessage *) inMessage uncitedTokens: (NSArray * __autoreleasing *) outUncitedTokens {
    
    if (!location) {
        return [NSMutableString stringWithString: address];
    }
    
    NSMutableArray  * uncitedTokens     = [[NSMutableArray alloc] init];
    NSMutableString * processedLocation = [NSMutableString stringWithString: location];
    NSDictionary    * parameters        = [inMessage parameters];
    
    for (NSString * replacementAttributeToken in locationReplacementAttributes) {
        NSString * replacementAttribute = [locationReplacementAttributes objectForKey: replacementAttributeToken];
        
        NSString * value = [parameters valueForKey: replacementAttribute];
        if (!value && !ignoreUncited) {
            [uncitedTokens addObject: replacementAttribute];
        }
        [processedLocation replaceOccurrencesOfString: replacementAttributeToken withString: [value stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding] options: 0 range: NSMakeRange(0, [processedLocation length])];
    }
    
    if (outUncitedTokens && [uncitedTokens count] > 0) {
        *outUncitedTokens = uncitedTokens;
    }
                                           
    return [NSMutableString stringWithFormat: @"%@%@", address, processedLocation];
}

- (NSString *) parameterStringForInMessage: (MGWebServiceInMessage *) inMessage uncitedTokens: (NSArray *) uncitedTokens {
    
    NSMutableString * parameterString = [[NSMutableString alloc] init];
    NSDictionary    * instanceData    = [inMessage instanceData];
    
    for (NSUInteger i = 0; i < [uncitedTokens count]; i++) {
        NSString * token = [uncitedTokens objectAtIndex: i];
        id tokenValue    = [instanceData objectForKey: token];
        
        if (!tokenValue) {
            @throw [MGRuntimeException exceptionWithName: @"Runtime Exception" reason: [NSString stringWithFormat: @"Message location %@ cited token \"%@\" but no vaue was found in the message %@", location, token, inMessage] userInfo: nil];
        }
        if (i == 1) {
            [parameterString appendFormat: @"%@=%@", [token stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding] , [tokenValue stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
        } else {
            [parameterString appendFormat: @"%@%@=%@", queryParameterSeparator, [token stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding] , [tokenValue stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
        }
    }
    if ([parameterString length] == 0) {
        return nil;
    }
    return parameterString;
}

@end

@implementation MGWebServiceHTTPSerializer (Initialization)

- (id) initWithBindingOperationDefinition: (MGWSDLBindingOperation *) aBindingOperation endpointDefinition: (MGWSDLEndpoint *) anEndpointDefinition messageReference: (MGWSDLBindingMessageReference *) aBindingMessageReference {
    
    if ((self = [super init])) {
        
        NSDictionary * operationExtensionProperties = [aBindingOperation extensionProperties] ;
        
        //
        // Location and Query building
        //
        address  = [anEndpointDefinition address];
        location = [operationExtensionProperties objectForKey: MGWSDLHTTPExtensionPropertyLocation];
        
        locationReplacementAttributes = [self locationReplacementAttributes: location];
        
        queryParameterSeparator = [operationExtensionProperties objectForKey: MGWSDLHTTPExtensionPropertyQueryParameterSeparator];
        if (!queryParameterSeparator) {
            queryParameterSeparator = MGWSDLHTTPExtensionValueQueryParameterSeparatorDefault;
        }
        
        id ignoreUncitedNumber = [operationExtensionProperties objectForKey: MGWSDLHTTPExtensionPropertyIgnoreUncited];
        if (ignoreUncitedNumber && [ignoreUncitedNumber isKindOfClass: [NSNumber class]]) {
            ignoreUncited = [ignoreUncitedNumber boolValue];
        } else {
            ignoreUncited = FALSE;
        }
    }
    
    return self;
}


- (NSDictionary *) locationReplacementAttributes: (NSString *) aLocation {
    
    NSMutableDictionary * replacementAttributes = [[NSMutableDictionary alloc] init];
    
    NSArray * addressComponents = [aLocation componentsSeparatedByString: @"/"];
    
    for (NSString * component in addressComponents) {
        if ([component hasPrefix: @"{"] && ![component hasPrefix: @"{{"]) {
            
            if ([component hasSuffix: @"}"] && ![component hasSuffix: @"}}"]) {
                NSRange keyRange = NSMakeRange(1, [component length] - 2);
                
                [replacementAttributes setValue: [component substringWithRange: keyRange] forKey: component];
            } else {
                @throw [MGInitializationException exceptionWithName: @"Initialization Exception" reason: [NSString stringWithFormat: @"Location \"%@\" replacement token does not have a closing }", aLocation] userInfo: nil];
            }
        }
    }
    if ([replacementAttributes count] > 0) {
        return [[NSDictionary alloc] initWithDictionary: replacementAttributes];
    }
    return nil;
}

@end
