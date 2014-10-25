//
//  MGConnect+EntityActionDefinition.m
//  MGConnect
//
//  Created by Tony Stone on 4/7/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGConnect+EntityActionDefinition.h"
#import "MGEntityActionDefinition+Private.h"
#import "MGWSDL.h"
#import "MGTraceLog.h"

NSString * const MGEntityActionList     = @"list";
NSString * const MGEntityActionRead     = @"read";
NSString * const MGEntityActionInsert   = @"insert";
NSString * const MGEntityActionUpdate   = @"update";
NSString * const MGEntityActionDelete   = @"delete";

#define kDefaultTimeout                 60
#define kDefaultURNPrefix               @""
#define kDefaultAssignMissingValuesNull YES;
#define kDefaultEntityArrayKeyPath      @""

@implementation MGEntityActionDefinition

#pragma mark - Required

- (NSString *) address {
    [self doesNotRecognizeSelector: _cmd];
    return nil;
}

- (NSDictionary *) actionLocations {
    [self doesNotRecognizeSelector: _cmd];
    return nil;
}

- (NSString *) remoteResourceUniqueIDElement {
    [self doesNotRecognizeSelector: _cmd];
    return nil;
}

- (NSString *) uniqueIDElement {
    [self doesNotRecognizeSelector: _cmd];
    return nil;
}

#pragma mark - Optional

- (NSString *) entityMappingRoot {
    return nil;
}

- (NSDictionary *) entityMapping {
    
    //
    // Note: return a one to one mapping from the entity.
    //       I'll need to store the entity in the webservice
    //
    return nil;
}

- (NSString *) entityArrayKeyPath {
    return kDefaultEntityArrayKeyPath;
}

- (NSString *) urnPrefix {
    return kDefaultURNPrefix;
}

- (BOOL) assignMissingValuesNull {
    return kDefaultAssignMissingValuesNull;
}

- (NSDictionary *) parametersForAction: (NSString *) anAction {
    return [NSArray array];
}

- (NSDictionary *) argumentsForAction: (NSString *) anAction {
    return [NSDictionary dictionary];
}

- (NSTimeInterval) timeout {
    return kDefaultTimeout;
}

- (MGWSDLDescription *) wsdl: (NSString *) anEntityName {
    
    MGWSDLDescription * wsdl = [[MGWSDLDescription alloc] init];
    
    MGWSDLInterface * interface = [[MGWSDLInterface alloc] initWithName: [anEntityName stringByAppendingString: @"Interface"]];
    MGWSDLBinding   * binding   = [[MGWSDLBinding alloc]   initWithName: [anEntityName stringByAppendingString: @"Binding"] type: @"http"];
    
    //
    // Should handle cookies
    //
    if ([self respondsToSelector: @selector(cookies)]) {
        [binding setExtensionPropertyValue: [NSNumber numberWithBool: [self cookies]] forKey: MGWSDLHTTPExtensionPropertyCookies];
    }

    // This is required so we don't check if it respondsToSelector
    NSDictionary * actionsLocations = [self actionLocations];
    
    //
    // For each action, setup an Operation
    //
    for (NSString * actionName in [actionsLocations allKeys]) {
        
        MGWSDLInterfaceOperation * interfaceOperation = [[MGWSDLInterfaceOperation alloc] initWithName: actionName messageExchangePattern: MGWSDLMessageExchangePatternInOut];
        MGWSDLBindingOperation   * bindingOperation   = [[MGWSDLBindingOperation alloc]   initWithName: actionName     interfaceOperation: interfaceOperation];

        id method   = nil;
        id location = nil;
        
        NSString * inputSerialization      = nil;
        NSString * outputSerialization     = nil;
        //NSString * transferEncodingDefault = nil;
        
        id actionInfo = [actionsLocations objectForKey: actionName];

        if (actionInfo) {
            if ([actionInfo isKindOfClass: [NSString class]] ) {
                
                if ([actionInfo length] > 0) {
                    location = (NSString *) actionInfo;
                }
            } else if ([actionInfo isKindOfClass: [NSDictionary class]]) {
               
                method = [[actionInfo allKeys] lastObject];
                
                if (![method isKindOfClass: [NSString class]]) {
                    @throw [MGInitializationException exceptionWithName: @"Initialization Exception" reason: [NSString stringWithFormat: @"Invalid action method class %@ specified in %@ for action \"%@\"", NSStringFromClass([method class]), NSStringFromClass([self class]), actionName] userInfo: nil];
                }
                
                location = [actionInfo objectForKey: method];
                
                if (![location isKindOfClass: [NSString class]]) {
                    @throw [MGInitializationException exceptionWithName: @"Initialization Exception" reason: [NSString stringWithFormat: @"Invalid action location class %@ specified in %@ for action \"%@\"", NSStringFromClass([location class]), NSStringFromClass([self class]), actionName] userInfo: nil];
                }
                
            } else {
                @throw [MGInitializationException exceptionWithName: @"Initialization Exception" reason: [NSString stringWithFormat: @"Invalid action location class %@ specified in %@ for action \"%@\"", NSStringFromClass([location class]), NSStringFromClass([self class]), actionName] userInfo: nil];
            }
        }
        
        if (!method) {
            if      (actionName == MGEntityActionList)   method = MGWSDLHTTPExtensionMethodGET;
            else if (actionName == MGEntityActionRead)   method = MGWSDLHTTPExtensionMethodGET;
            else if (actionName == MGEntityActionInsert) method = MGWSDLHTTPExtensionMethodPOST;
            else if (actionName == MGEntityActionUpdate) method = MGWSDLHTTPExtensionMethodPUT;
            else if (actionName == MGEntityActionDelete) method = MGWSDLHTTPExtensionMethodDELETE;
            else {
                method = MGWSDLHTTPExtensionMethodGET;
                
                LogWarning(@"No method specified for action %@ defaulting to %@", actionName, method);
            }
        }
        
        [bindingOperation setExtensionPropertyValue: method forKey: MGWSDLHTTPExtensionPropertyMethod];
        
        // Location is not required.
        if (location) {
            [bindingOperation setExtensionPropertyValue: location forKey: MGWSDLHTTPExtensionPropertyLocation];
        }

        if ([self respondsToSelector: @selector(inputSerialization)]) {
            inputSerialization = [self inputSerialization];
        }
        if ([self respondsToSelector: @selector(outputSerialization)]) {
            outputSerialization = [self outputSerialization];
        }
        
        //
        // Setup the serialization format
        //
        if (method == MGWSDLHTTPExtensionMethodGET || method == MGWSDLHTTPExtensionMethodDELETE) {
            
            if (!inputSerialization) {
                inputSerialization  = MGWSDLHTTPExtensionValueSerializationURLEncoded;
            }
            if (!outputSerialization) {
                outputSerialization = MGWSDLHTTPExtensionValueSerializationJSON;
            }
        }
        else if (method == MGWSDLHTTPExtensionMethodPOST || method == MGWSDLHTTPExtensionMethodPUT) {
            
            if (!inputSerialization) {
                inputSerialization  = MGWSDLHTTPExtensionValueSerializationJSON;
            }
            if (!outputSerialization) {
                outputSerialization = MGWSDLHTTPExtensionValueSerializationJSON;
            }
        }
               
        [bindingOperation setExtensionPropertyValue: inputSerialization  forKey: MGWSDLHTTPExtensionPropertyInputSerialization];
        [bindingOperation setExtensionPropertyValue: outputSerialization forKey: MGWSDLHTTPExtensionPropertyOutputSerialization];
        
        //
        // Set up the abstract message format
        //
        MGWSDLInterfaceMessageReference * inputInterfaceMessage  = [[MGWSDLInterfaceMessageReference alloc] initWithName: [actionName stringByAppendingString: @"Input"]  messageLabel: MGWSDLMessageDirectionIn  direction: MGWSDLMessageDirectionIn  messageContentModel: MGWSDLMessageContentModelElement];
        MGWSDLInterfaceMessageReference * outputInterfaceMessage = [[MGWSDLInterfaceMessageReference alloc] initWithName: [actionName stringByAppendingString: @"Output"] messageLabel: MGWSDLMessageDirectionOut direction: MGWSDLMessageDirectionOut messageContentModel: MGWSDLMessageContentModelElement];
        
        [interfaceOperation addInterfaceMessageReference: inputInterfaceMessage];
        [interfaceOperation addInterfaceMessageReference: outputInterfaceMessage];
        
        //
        // Set up the binding messages
        //
        MGWSDLBindingMessageReference * inputBindingMessage  =[[MGWSDLBindingMessageReference alloc] initWithName: [actionName stringByAppendingString: @"Input"]  interfaceMessageReference: inputInterfaceMessage];
        MGWSDLBindingMessageReference * outputBindingMessage =[[MGWSDLBindingMessageReference alloc] initWithName: [actionName stringByAppendingString: @"Output"] interfaceMessageReference: outputInterfaceMessage];
        
        //
        // Add the specified header fields from the action definition
        //
        if ([self respondsToSelector: @selector(headers)]) {
            NSDictionary * headers = [self headers];
            
            for (NSString * header in headers) {
                MGWSDLExtensionElement * inputExtensionElement = [[MGWSDLExtensionElement alloc] initWithName: header element: MGWSDLHTTPExtensionElementHeader type: @"string" required: YES];
                [inputExtensionElement setValue: [headers objectForKey: header]];
                [inputBindingMessage addExtensionElement: inputExtensionElement];
            }
        }

        //
        // Default Transfer coding
        //
        [inputBindingMessage  setExtensionPropertyValue: @"identity;q=0.2 *;q=0"                             forKey: MGWSDLHTTPExtensionPropertyTransferCoding];
        [outputBindingMessage setExtensionPropertyValue: @"gzip;q=1.0, compress;q=0.5, identity;q=0.2 *;q=0" forKey: MGWSDLHTTPExtensionPropertyTransferCoding];
        
        [bindingOperation addBindingMessageReference: inputBindingMessage];
        [bindingOperation addBindingMessageReference: outputBindingMessage];
        
        //
        // Add themto the interface and binding
        //
        [interface addInterfaceOperation: interfaceOperation];
        [binding     addBindingOperation: bindingOperation];
    }

    MGWSDLEndpoint * endpoint = [[MGWSDLEndpoint alloc] initWithName: [anEntityName stringByAppendingString: @"Endpoint"] binding: binding];
    
    [endpoint setAddress: [self address]];
    
    MGWSDLService  * service  = [[MGWSDLService alloc]  initWithName: [anEntityName stringByAppendingString: @"Service"] interface: interface endpoint: endpoint];
    
    [wsdl addInterface: interface];
    [wsdl addBinding: binding];
    [wsdl addService: service];
    
    return wsdl;
}

@end

@implementation MGConnect (EntityActionDefinition)

@end
