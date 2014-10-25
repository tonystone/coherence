//
//  MGConnect+EntityActionDefinitionTests.m
//  MGConnect
//
//  Created by Tony Stone on 4/13/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//
#import "MGConnectTestCommon.h"

#import "MGConnect+EntityActionDefinition.h"
#import "MGEntityActionDefinition+Private.h"
#import "MGWebService.h"
#import "MGWebServiceMessage.h"
#import "MGWebServiceInMessage.h"
#import "MGWebServiceOutMessage.h"
#import "MGWebServiceOperation.h"

@interface MGConnect_EntityActionDefinitionTests : MGConnectTestCommon @end

@implementation MGConnect_EntityActionDefinitionTests


- (void)setUp
{
    [super setUp];
    
    // Force RM to load
    (void) [MGConnect sharedManager];
    
    [self login];
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testWebServiceCreation
{
    
    NSDictionary * actionDefinitions = @{@"Server":     @"ServerEntityActionDefinition"};
    
    NSMutableArray * webServices = [[NSMutableArray alloc] init];
    
    for (NSString * entityName in actionDefinitions) {
        NSString * actionClassName = [actionDefinitions objectForKey: entityName];
        Class      actionClass     = NSClassFromString(actionClassName);
        
        MGEntityActionDefinition * actionDefinition = [[actionClass alloc] init];
        
        MGWSDLDescription * wsdlDescription = [actionDefinition wsdl: entityName];
        
        STAssertNotNil(wsdlDescription, @"Failed to generate wsdl from Action");
        
        NSArray * actionWebServices = [MGWebService webServicesForWSDLDescription: wsdlDescription];
        
        [webServices addObjectsFromArray: actionWebServices];
    }
    
    STAssertTrue([webServices count] == [actionDefinitions count], @"Did not create all required webServices");
}

//- (void) testWebServiceExecutionCloudRead {
//    
//    Class actionClass = NSClassFromString(@"CloudEntityActionDefinition");
//    
//    MGEntityActionDefinition * actionDefinition = [[actionClass alloc] init];
//    
//    MGWSDLDescription * wsdlDescription = [actionDefinition wsdl: @"Cloud"];
//    
//    NSArray * actionWebServices = [MGWebService webServicesForWSDLDescription: wsdlDescription];
//    
//    MGWebService * aWebService = [actionWebServices lastObject];
//    
//    MGWebServiceOperation * listOperation = [aWebService operationForName: MGEntityActionRead];
//    
//    MGWebServiceInMessage * inMessage = [[MGWebServiceInMessage alloc] init];
//    [inMessage setValue: @"232" forParameter: @"cloudID"];
//    
//    MGWebServiceOutMessage * outMessage = [listOperation execute: inMessage];
//    
//    //STAssertNotNil(outMessage, @"No message produced from Web Service Operation");
//}
//
//- (void) testWebServiceExecutionCloudList {
//    
//    Class actionClass = NSClassFromString(@"CloudEntityActionDefinition");
//        
//    MGEntityActionDefinition * actionDefinition = [[actionClass alloc] init];
//        
//    MGWSDLDescription * wsdlDescription = [actionDefinition wsdl: @"Cloud"];
//    
//    NSArray * actionWebServices = [MGWebService webServicesForWSDLDescription: wsdlDescription];
//    
//    MGWebService * aWebService = [actionWebServices lastObject];
//    
//    MGWebServiceOperation * listOperation = [aWebService operationForName: MGEntityActionList];
//    
//    MGWebServiceInMessage * inMessage = [[MGWebServiceInMessage alloc] init];
//    
//    MGWebServiceMessage * outMessage = [listOperation execute: inMessage];
//    
//    //STAssertNotNil(outMessage, @"No message produced from Web Service Operation");
//}
//
//- (void) testWebServiceExecutionDeploymentList {
//    
//    Class actionClass = NSClassFromString(@"DeploymentEntityActionDefinition");
//    
//    MGEntityActionDefinition * actionDefinition = [[actionClass alloc] init];
//    
//    MGWSDLDescription * wsdlDescription = [actionDefinition wsdl: @"Deployment"];
//    
//    NSArray * actionWebServices = [MGWebService webServicesForWSDLDescription: wsdlDescription];
//    
//    MGWebService * aWebService = [actionWebServices lastObject];
//    
//    MGWebServiceOperation * listOperation = [aWebService operationForName: MGEntityActionList];
//    
//    MGWebServiceInMessage * inMessage = [[MGWebServiceInMessage alloc] init];
//    
//    MGWebServiceMessage * outMessage = [listOperation execute: inMessage];
//    
//    //STAssertNotNil(outMessage, @"No message produced from Web Service Operation");
//}

- (void) testWebServiceExecutionServerList {
    
    Class actionClass = NSClassFromString(@"ServerEntityActionDefinition");
    
    MGEntityActionDefinition * actionDefinition = [[actionClass alloc] init];
    
    MGWSDLDescription * wsdlDescription = [actionDefinition wsdl: @"Server"];
    
    NSArray * actionWebServices = [MGWebService webServicesForWSDLDescription: wsdlDescription];
    
    MGWebService * aWebService = [actionWebServices lastObject];
    
    MGWebServiceOperation * listOperation = [aWebService operationForName: MGEntityActionList];
    
    MGWebServiceInMessage * inMessage = [[MGWebServiceInMessage alloc] init];
    
    MGWebServiceMessage * outMessage = [listOperation execute: inMessage];
    
    //STAssertNotNil(outMessage, @"No message produced from Web Service Operation");
}

@end
