//
//  MGWebService.h
//  MGConnect
//
//  Created by Tony Stone on 4/9/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@class MGWSDLDescription;
@class MGWebServiceOperation;

@interface MGWebService : NSObject

/**
 What the interface name
 */
- (NSString *) name;

/**
 Get all the operations supported
 */
- (NSArray *) operations;

/**
 Get an operation by name
 
 If it does not exists, this method will return nil
 */
- (MGWebServiceOperation *) operationForName: (NSString *) anOperationName;


@end

@interface MGWebService (Initialization)

/**
 Creates a new webService for the WSDL description DOM object passed in.
 */
+ (NSArray *) webServicesForWSDLDescription: (MGWSDLDescription *) aDescription;

@end
