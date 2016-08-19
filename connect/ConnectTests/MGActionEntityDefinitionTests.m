//
//  MGActionEntityDefinitionTests.m
//  MGConnect
//
//  Created by Tony Stone on 4/19/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//
#import <XCTest/XCTest.h>

#import "MGActionEntityDefinitionTests.h"
#import "MGEntityActionDefinition+Private.h"

#import "Server.h"
#import "ServerEntityActionDefinition.h"

#import "MGObjectMapper.h"
#import "MGXPathV1ObjectMapper.h"
#import "MGSAXYObjectMapper.h"


@interface MGActionEntityDefinitionTests : XCTestCase @end

@implementation MGActionEntityDefinitionTests {
    NSManagedObjectModel * dataCacheModel;
}


- (void)setUp
{
    [super setUp];
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    
    NSURL * dataCacheModelURL = [bundle URLForResource: @"DataCache" withExtension: @"mom"];
    dataCacheModel = [[NSManagedObjectModel alloc] initWithContentsOfURL: dataCacheModelURL];
    
}

- (void)tearDown
{
    // Tear-down code here.
    
    dataCacheModel = nil;
    
    [super tearDown];
}

- (void) testServerDefinitionTest {
    
    NSError * error = nil;
    
    NSEntityDescription * entity = [[dataCacheModel entitiesByName] objectForKey: @"Server"];
    
    MGEntityActionDefinition * actionDefinition = [[ServerEntityActionDefinition alloc] init];
    
    NSLog(@"\rObject root: %@\rObject mapping: %@\r", [actionDefinition mappingRoot], [actionDefinition mapping]);
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *xml    = [NSString stringWithContentsOfURL: [bundle URLForResource: @"server" withExtension: @"xml"] encoding: NSUTF8StringEncoding error: &error];
    
    NSLog(@"\rxml: %@\r", xml);
    
    Class enityClass = NSClassFromString([entity managedObjectClassName]);
    
    id (^objectAllocationBlock)(void) = ^{
        return [[NSManagedObject alloc] initWithEntity: entity insertIntoManagedObjectContext: nil];
    };
    
    NSObject <MGObjectMapper> * objectMapper = [[MGXPathV1ObjectMapper alloc] initWithObjectClass: enityClass objectAllocationBlock: objectAllocationBlock objectMapping: [actionDefinition mapping] objectRoot: [actionDefinition mappingRoot]];
    
    NSArray * servers = [objectMapper map: [xml dataUsingEncoding: NSUTF8StringEncoding]];
    
    NSLog(@"\rServers: %@\r", servers);
}

@end


