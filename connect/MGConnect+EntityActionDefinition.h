//
//  MGConnect+EntityActionDefinition.h
//  MGConnect
//
//  Created by Tony Stone on 4/7/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGConnect.h"
#import "MGConnect+EntityAction.h"

/**
 Main protocol to define an entityAction
 
 */
@protocol MGEntityActionDefinition <NSObject>

/**
 Required for EntityActionDefinition
 */
#pragma mark - EntityActionDefinition (Required)

@required

    /*
     The base address for the webService
     
     Example:
     
     https://my.rightscale.com/api
     
     */
    - (NSString *) address;

    /**
     
     The {actionLocations} property MAY cite local names of elements from the instance data of the message to be
     serialized in request IRI by enclosing the element name within curly braces (e.g. "temperature/{town}"):
     
     When constructing the request IRI, each pair of curly braces (and enclosed element name) is replaced by the possibly 
     empty single value of the corresponding element. If a local name appears more than once, the elements are used in the 
     order they appear in the instance data. It is an error for this element to carry an xs:nil attribute whose value is "true".
     
     A double curly brace (i.e. "{{" or "}}") MAY be used to include a single, literal curly brace in the request IRI.
     
     Strings enclosed within single curly braces MUST be element names from the instance data of the input message; local names within 
     single curly braces not corresponding to an element in the instance data are a fatal error.†
     
     Example 1:
     
     RESTful urls
     
        /clouds/{cloudID}/instances/{instanceID}
     
     Paramatized URLs
     
        /instances?id={instanceID}&cloud_id={cloudID}
     
     */
    - (NSDictionary *) actionLocations;


#pragma mark - EntityActionDefinition (Optional)

@optional

    - (NSString *) authenticationScheme;
    - (NSString *) authenticationRealm;

    /**
     
     */
    - (NSDictionary *) parametersForAction: (NSString *) anAction;

    /*
     */
    - (NSDictionary *) argumentsForAction: (NSString *) anAction;

    /**
     The amount of time (in seconds) that your WebService should wait for a result from the server.
     
     Default is 30 seconds.
     */
    - (NSTimeInterval) timeout;

    /**
     Optional define header fields and values to be passed to the web service on each call.
     */
    - (NSDictionary *) headers;

    /**
     Should we handle cookies for this actions webserivces
     */
    - (BOOL) cookies;

    /**
     Valid Values are;
     
        "application/x-www-form-urlencoded"
        "application/json"
        "application/xml"

     */
    - (NSString *) inputSerialization;

    /**
     Valid Values are;
     
        "application/xml"
        "application/json"
     
     Please use the constents below to set the values.

        MGWSDLHTTPExtensionValueSerializationJSON
        MGWSDLHTTPExtensionValueSerializationXML
     */
    - (NSString *) outputSerialization;

/**
 Required for Action Mapping
 */
#pragma mark - EntityMapping (Required)

@required

    /**
     */
    - (NSString *) uniqueIDElement;

#pragma mark - EntityMapping (Optional)

@optional
    /**
     
     Key value pairs mapping API result set elements to CoreData model fields
     
     Example:
     
     Instances
     
     Key (CoreData)         Value (JSON Keypath)
     ---------------------- ----------------
     instanceID             id
     cloudID                cloud_id
     publicIPAddresses      public_ip_addresses
     privateIPAddresses     private_ip_addresses
     
     
     Subnets
     
     Key (CoreData)         Value (keyPath)
     ---------------------- ----------------
     
     name                   name
     visibility             visibility
     resourceUID            resource_uid
     description            description
     
     
     */
    - (NSDictionary *)    mapping;
    - (NSString *)        mappingRoot;

    /**
     */
    - (NSString *) entityArrayKeyPath;

    /**
     
     */
    - (NSString *) urnPrefix;

    /**
     
     */
    - (BOOL) assignMissingValuesNull;

@end

@interface MGEntityActionDefinition : NSObject <MGEntityActionDefinition> @end

@interface MGConnect (EntityActionDefinition) @end
