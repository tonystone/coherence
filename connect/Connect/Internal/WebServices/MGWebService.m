//
//  MGWebServiceInterface.m
//  MGConnect
//
//  Created by Tony Stone on 4/9/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGWebService.h"
#import "MGRuntimeException.h"
#import "MGInitializationException.h"
#import "MGWSDL.h"
#import "MGWebServiceHTTPOperation.h"
#import "MGTraceLog.h"

@interface MGWebService ()
- (void) addOperation: (MGWebServiceOperation *) anOperation;
@end

@implementation MGWebService  {
    NSString             * name;
    //
    // NOTE: Currently only http bindings are supported
    //
    NSMutableDictionary  * httpOperationsByName;
}

- (NSString *) name {
    return name;
}

- (NSArray *) operations {
    return [httpOperationsByName allKeys];
}

- (MGWebServiceOperation *) operationForName: (NSString *) anOperationName {
    
    NSParameterAssert(anOperationName != nil);
    
    return [httpOperationsByName objectForKey: anOperationName];
}

- (void) addOperation: (MGWebServiceOperation *) anOperation {
    
    NSParameterAssert(anOperation != nil);
    
    if ([httpOperationsByName objectForKey: [anOperation name]]) {
        @throw [MGRuntimeException exceptionWithName: @"Runtime Exception" reason: [NSString stringWithFormat: @"%@ \"%@\" already contains an operation named %@, you can not add it again.", NSStringFromClass([self class]), [self name], [anOperation name]] userInfo: nil];
    }
    
    [httpOperationsByName setValue: anOperation forKey: [anOperation name]];
}


@end

@implementation MGWebService (Initialization)

+ (NSArray *) webServicesForWSDLDescription: (MGWSDLDescription *) aDescription {
    
    NSParameterAssert(aDescription != nil);
    
    LogTrace(1, @"Generating WebServices...");
    LogTrace( 4, @"Using WSDL Description: %@", aDescription);
    
    NSMutableArray * webServices = [[NSMutableArray alloc] init];
    
    NSDictionary * services = [aDescription services];
    //
    // Start at the service level and work your way down
    // the tree from there.
    //
    for (NSString  * serviceName in [services allKeys]) {
        MGWSDLService * serviceDefinition = [services objectForKey: serviceName];
    
        [webServices addObject: [[MGWebService alloc] initWithServiceDefinition: serviceDefinition]];
    }
    
    LogTrace(1, @"WebService generation complete");
    
    return webServices;
}


- (id) initWithServiceDefinition: (MGWSDLService *) aServiceDefinition {
    
    NSParameterAssert(aServiceDefinition != nil);
    
    name = [aServiceDefinition name];
    
    LogTrace(1, @"Creating WebService \"%@\"...", name);
    
    if ((self = [super init])) {

        httpOperationsByName = [[NSMutableDictionary alloc] init];
        
        for (MGWSDLEndpoint * endpointDefinition in [[aServiceDefinition endpoints] allValues]) {
            MGWSDLBinding * bindingDefinition = [endpointDefinition binding];
            
            if ([[[bindingDefinition type] lowercaseString] isEqualToString: @"http"]) {
                [self initializeOperationsWithBindingDefinition: bindingDefinition endpointDefinition: endpointDefinition];
            } else {
                LogWarning(@"binding  %@ of type %@ is not supported, binding ignored", [bindingDefinition name], [bindingDefinition type]);
            }
        }
    }
    LogTrace(1, @"WebService \"%@\" created", name);
    return self;
}

- (void) initializeOperationsWithBindingDefinition: (MGWSDLBinding *) aBindingDefinition endpointDefinition: (MGWSDLEndpoint *) anEndpointDeifnition {
    
    Class operationClass = nil;
    
    if (![[[aBindingDefinition type] lowercaseString] isEqualToString: @"http"]) {
        @throw [MGInitializationException exceptionWithName: @"Initialization Execption" reason: [NSString stringWithFormat: @"WebServices do not support a binding of type \"%@\" at this point.  Web service not created for interface \"%@\"", [aBindingDefinition type], name] userInfo: nil];
    } else {
        //
        // Note: we explicitly reference the state class here so itgets compiled into the app
        //
        operationClass = [MGWebServiceHTTPOperation class];
    }
    
    for (MGWSDLBindingOperation * aBindingOperation in [[aBindingDefinition bindingOperations] allValues]) {
        MGWebServiceOperation * operation = [[operationClass alloc] initWithBindingBindingDefinition: aBindingDefinition operationDefinition: aBindingOperation endpointDefinition: anEndpointDeifnition webService: self];
        
        [httpOperationsByName setObject: operation forKey: [operation name]];
    }
}

@end
