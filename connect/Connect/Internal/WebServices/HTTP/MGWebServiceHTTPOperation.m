//
//  MGWebServiceOperationHTTPBinding.m
//  MGResourceManager
//
//  Created by Tony Stone on 4/9/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGWebServiceHTTPOperation.h"
#import "MGWebService.h"
#import "MGWSDL.h"
#import "MGInitializationException.h"
#import "MGRuntimeException.h"
#import "MGWebServiceMessage.h"
#import "MGWebServiceInMessage.h"
#import "MGWebServiceOutMessage.h"
#import "MGTraceLog.h"

#import "MGWebServiceHTTPSerializer.h"
#import "MGWebServiceHTTPURLEncodedSerializer.h"
#import "MGWebServiceHTTPJSONSerializer.h"
#import "MGWebServiceHTTPXMLSerializer.h"

#import "MGWebServiceHTTPDeserializer.h"
#import "MGWebServiceHTTPJSONDeserializer.h"
#import "MGWebServiceHTTPXMLDeserializer.h"

static NSDictionary * httpOperationDefaultHeaders;
static NSDictionary * serializerClasses;
static NSDictionary * deserializerClasses;

//
// Initialize internal static structures
//
__attribute__((constructor)) static void initialize_internal_statics() {
    
    httpOperationDefaultHeaders = @{};
    
    serializerClasses   = @{MGWSDLHTTPExtensionValueSerializationURLEncoded:        [MGWebServiceHTTPURLEncodedSerializer class],
                            MGWSDLHTTPExtensionValueSerializationJSON:              [MGWebServiceHTTPJSONSerializer class],
                            MGWSDLHTTPExtensionValueSerializationXML:               [MGWebServiceHTTPXMLSerializer class]};

    deserializerClasses = @{MGWSDLHTTPExtensionValueSerializationJSON:              [MGWebServiceHTTPJSONDeserializer class],
                            MGWSDLHTTPExtensionValueSerializationXML:               [MGWebServiceHTTPXMLDeserializer class]};

}

//
// Main Implementation
//
@implementation MGWebServiceHTTPOperation  {
    NSString     * name;
    NSString     * method;
    NSString     * address;
    NSString     * location;

    BOOL           cookies;
    NSDictionary * httpHeaders;

    MGWebServiceHTTPSerializer   * serializer;
    MGWebServiceHTTPDeserializer * deserializer;
    
    MGWebService __unsafe_unretained * webService;
    MGWebServiceEndpoint             * endpoint;
}

- (NSString *) name {
    return name;
}


- (NSURLRequest *) requestForMessage: (MGWebServiceInMessage *) inMessage {
    
    NSURL * url = [serializer serializedURLForMethod: method inMessage: inMessage];
    
    // Create the request.
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL: url cachePolicy: NSURLRequestReloadIgnoringLocalCacheData timeoutInterval: 60];
    
    [request setHTTPMethod: method];
    [request setHTTPShouldHandleCookies: cookies];
    
    for (NSString * key in [httpHeaders allKeys]) {
        [request setValue: [httpHeaders valueForKey: key] forHTTPHeaderField: key];
    }

    [request setHTTPBody: [serializer serializedMessageBodyForMethod: method inMessage: inMessage]];
    
    return request;
}

- (MGWebServiceOutMessage *) execute: (MGWebServiceInMessage *) inMessage {
    
    NSHTTPURLResponse * response = nil;
    NSError           * error    = nil;
    
    NSData * body = [self executeRequest: [self requestForMessage: inMessage] response: &response error: &error];

    MGWebServiceOutMessage * outMessage = nil;
    
    if (response && ([response statusCode] == 200 || [response statusCode] == 202)) {
        outMessage = [deserializer deserializedResponse: response responseData: body];
    } else {
        // Process fault
    }
    return outMessage;
}

- (NSData *) executeRequest: (NSURLRequest *) request response: (NSHTTPURLResponse * __autoreleasing *) outResponse error: (NSError * __autoreleasing *) outError {
    
    NSParameterAssert(request != nil);

    NSHTTPURLResponse * response = nil;
    NSError           * error    = nil;
    
    LogInfo(@"%@", [self requestDescription: request]);
    
    // Make the synchronous request
    NSData * returnedData = [NSURLConnection sendSynchronousRequest:request returningResponse: &response error: &error];
    
    LogInfo(@"%@", response ? [self responseDescription: response] :[self noResponseDescription: request error: error]);
    LogTrace(1, @"\nReturned Data = {\n%@\n}\n", returnedData ? [[NSString alloc] initWithData: returnedData encoding:NSUTF8StringEncoding] : nil);
    
    if (outResponse && response) *outResponse = response;
    if (outError    && error)    *outError    = error;

    return returnedData;
}

- (NSString *) requestDescription: (NSURLRequest *) request {
    
    NSString * description = nil;
    
    description = @"\n\nRequest = {";
    description = [description stringByAppendingFormat:@"\n   %s: %@", "URL",    [[request URL] debugDescription]];
    description = [description stringByAppendingFormat:@"\n   %s: %f", "timeout",[request timeoutInterval]];
    description = [description stringByAppendingFormat:@"\n   %s: %@", "method", [request HTTPMethod]];
    description = [description stringByAppendingFormat:@"\n   %s: %@", "allHTTPHeaderFields", [request allHTTPHeaderFields]];
    description = [description stringByAppendingFormat:@"\n   %s: %@", "HTTP Body", [[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding]];
    description = [description stringByAppendingFormat:@"\n}\n\n"];
    
    return description;
}

- (NSString *) responseDescription: (NSHTTPURLResponse *) response {
    
    NSString * description = nil;
    
    description = [NSString stringWithFormat:@"\n\nResponse = {"];
    description = [description stringByAppendingFormat:@"\n   %s: %@", "URL",    [[response URL] debugDescription]];
    description = [description stringByAppendingFormat:@"\n   %s: %d - %@", "HTTP statusCode", [response statusCode], [NSHTTPURLResponse localizedStringForStatusCode: [response statusCode]]];
    description = [description stringByAppendingFormat:@"\n   %s: %@", "allHTTPHeaderFields", [response allHeaderFields]];
    description = [description stringByAppendingFormat:@"\n}\n\n"];
    
    return description;
}

- (NSString *) noResponseDescription: (NSURLRequest *) request error: (NSError *) error {
    return [NSString stringWithFormat: @"No response for request with URL %@%@", [[request URL] debugDescription], error ? [NSString stringWithFormat: @" error: %@", error] : @""];
}

- (NSString *) description {
    NSMutableString * description = [NSMutableString stringWithFormat: @"\r{\r\tHTTP Operation: %@\r\tmethod: %@\r\taddress: %@\r\tlocation: %@", name, method, address, location];
    
    if (httpHeaders && [httpHeaders count] > 0) {
        [description appendFormat: @"\r\theaders: %@", httpHeaders];
    }

    [description appendString: @"\r}\r"];
    
    return description;
}

@end


@implementation MGWebServiceHTTPOperation (Initialization)

- (id) initWithBindingBindingDefinition: (MGWSDLBinding *) aBindingDefinition operationDefinition: (MGWSDLBindingOperation *) aBindingOperation  endpointDefinition: (MGWSDLEndpoint *) anEndpointDefinition webService: (MGWebService __unsafe_unretained *) aWebService {
    
    name = [[aBindingOperation interfaceOperation] name];
    
    LogTrace(1, @"Creating operation \"%@\"...", name);
    
    if ((self = [super initWithBindingBindingDefinition: aBindingDefinition operationDefinition: aBindingOperation endpointDefinition: anEndpointDefinition webService: aWebService])) {

        webService = aWebService;
        
        NSMutableDictionary * systemHeaders = [[NSMutableDictionary alloc] initWithDictionary: httpOperationDefaultHeaders];
        
        NSDictionary * operationExtensionProperties = [aBindingOperation extensionProperties] ;
        
        method = [operationExtensionProperties objectForKey: MGWSDLHTTPExtensionPropertyMethod];
        if (!method) {
            @throw [MGInitializationException exceptionWithName: @"Initialization Exception" reason:  [NSString stringWithFormat: @"HTTP Operation %@ does not have a method in the binding definition, can not create operation", [self name]] userInfo: nil];
        }
        
        id handleCookies = [[aBindingDefinition extensionProperties] objectForKey: MGWSDLHTTPExtensionPropertyCookies];
        if (handleCookies && [handleCookies isKindOfClass: [NSNumber class]]) {
            cookies = [handleCookies boolValue];
        } else {
            cookies = FALSE;
        }
        
        //
        // Location and Query building
        //
        address  = [anEndpointDefinition address];
        location = [operationExtensionProperties objectForKey: MGWSDLHTTPExtensionPropertyLocation];
        
        //
        // Get the serialization of the input and output
        //
        NSString * inputSerialization  = [operationExtensionProperties objectForKey: MGWSDLHTTPExtensionPropertyInputSerialization];
        NSString * outputSerialization = [operationExtensionProperties objectForKey: MGWSDLHTTPExtensionPropertyOutputSerialization];
        
        Class inputSerializationClass  = [serializerClasses   objectForKey: inputSerialization];
        Class outputSerializationClass = [deserializerClasses objectForKey: outputSerialization];
        
        if (!inputSerializationClass) {
            @throw [MGInitializationException exceptionWithName: @"Initialization Exception" reason: [NSString stringWithFormat: @"HTTP Operation %@ does not support the specified inputSerialization \"%@\"", [self name], inputSerialization] userInfo: nil];
        }
        if (!outputSerializationClass) {
            @throw [MGInitializationException exceptionWithName: @"Initialization Exception" reason: [NSString stringWithFormat: @"HTTP Operation %@ does not support the specified outputSerialization \"%@\"", [self name], outputSerialization] userInfo: nil];
        }
        
        serializer   = [[inputSerializationClass  alloc] initWithBindingOperationDefinition: aBindingOperation endpointDefinition: anEndpointDefinition messageReference: nil];
        deserializer = [[outputSerializationClass alloc] init];
        
        // Set the content type for these method types for the inputSerilialization
        if (method == MGWSDLHTTPExtensionMethodPOST || method == MGWSDLHTTPExtensionMethodPUT) {
            [systemHeaders setValue: inputSerialization forKey: @"Content-Type"];
        }
        [systemHeaders setValue: outputSerialization forKey: @"Accept"];
        
        //
        //  Now that everything else is setup we can create the headers and append any user header with them
        //
        //
        // The headers are for both input and output
        //
        httpHeaders = [self headersForBindingOperationDefinition: aBindingOperation systemHeaders: systemHeaders];
    }
    
    LogTrace(2, @"Operation \"%@\" info: %@", name, [self description]);
    LogTrace(1, @"Operation \"%@\" created", name);
    return self;
}


- (NSDictionary *) headersForBindingOperationDefinition: (MGWSDLBindingOperation *) aBindingOperation systemHeaders: (NSDictionary *) systemHeaders {
    
    //
    // Prime with the system header so that they get overridden by any values from the user
    //
    NSMutableDictionary * headers = [[NSMutableDictionary alloc] initWithDictionary: systemHeaders];
    
    NSDictionary * messageReferences = [aBindingOperation bindingMessageReferences];
    
    for (NSString * messageReferenceKey in [messageReferences allKeys]) {
        MGWSDLBindingMessageReference * aMessageReference = [messageReferences objectForKey: messageReferenceKey];
        
        //
        // Process the extensions for this message
        //
        NSDictionary * messageExtensionProperties = [aMessageReference extensionProperties];
        
        NSString * transferCoding = [messageExtensionProperties objectForKey: MGWSDLHTTPExtensionPropertyTransferCoding];
        if (transferCoding) {
            NSString * direction = [[aMessageReference interfaceMessageReference] direction];
            
            if (direction == MGWSDLMessageDirectionIn) {
                [headers setValue: transferCoding forKey: @"Content-Encoding"];                
            } else if (direction == MGWSDLMessageDirectionOut) {
                [headers setValue: transferCoding forKey: @"Accept-Encoding"];
            }
        }
        //
        // Now process any special headers
        //
        NSArray * messageHeaders = [[[aMessageReference extensionElements] allValues] filteredArrayUsingPredicate: [NSPredicate predicateWithFormat: @"SELF.element == %@", MGWSDLHTTPExtensionElementHeader]];
        for (MGWSDLExtensionElement * headerElement in messageHeaders) {
            if ([headerElement value]) {
                [headers setValue: [headerElement value] forKey: [headerElement name]];
            } else {
                @throw [MGInitializationException exceptionWithName: @"Initialization Exception" reason: [NSString stringWithFormat: @"Header \"%@\" is missing a value", [headerElement name]] userInfo: nil];
            }
        }
    }
    if ([headers count] > 0) {
        return [[NSDictionary alloc] initWithDictionary: headers];
    }
    
    return nil;
}

@end
