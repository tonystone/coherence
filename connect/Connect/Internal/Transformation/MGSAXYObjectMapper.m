//
//  MGObjectXMLMapper.m
//  MGConnect
//
//  Created by Tony Stone on 4/20/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGSAXYObjectMapper.h"
#import "MGTraceLog.h"

#import <CoreData/CoreData.h>

#import "OXmlReader.h"
#import "OXmlWriter.h"
#import "OXmlMapper.h"
#import "OXmlElementMapper.h"
#import "OXmlXPathMapper.h"

@implementation MGSAXYObjectMapper {
    OXmlReader * reader;
    OXmlWriter * writer;
}

- (id) initWithObjectClass: (Class) objectClass objectAllocationBlock: (id (^)(void)) objectAllocationBlockOrNil objectMapping: (NSDictionary *) objectMapping objectRoot: (NSString *) objectRootOrNil dateFormatter: (NSDateFormatter *) dateFormatterOrNil {
    
    NSParameterAssert(objectClass != nil);
    NSParameterAssert(objectMapping != nil);
    
    if ((self = [super init])) {
        [self createOXmlMapperWithObjectClass: objectClass objectAllocationBlock: objectAllocationBlockOrNil objectMapping: objectMapping objectRoot: objectRootOrNil dateFormatter: dateFormatterOrNil];
    }
    return self;
}
 
- (NSArray *) map: (NSData *)data {
    
    NSArray * results = [reader readXml: [[NSXMLParser alloc] initWithData: data]];
    
    if ([reader errors]) {
        LogError(@"%@", [reader errors]);
    }
    
    return results;
}

- (NSData *) reverseMap:(NSArray *)objects {
    return [[writer writeXml: objects] dataUsingEncoding: NSUTF8StringEncoding];
}

#pragma mark - Private methods

- (void) createOXmlMapperWithObjectClass: (Class) objectClass objectAllocationBlock: (id (^)(void)) objectAllocationBlock objectMapping: (NSDictionary *) objectMapping objectRoot: (NSString *) objectRootOrNil dateFormatter: (NSDateFormatter *) dateFormatter {

    NSString * objectRoot = objectRootOrNil;
    
    // Default the values that can be nil if they are nil
    if (!objectRoot) {
        objectRoot = @"/";
    }
    
    // Create the primary elements
    OXmlElementMapper * rootElement   = [OXmlElementMapper rootXPath: objectRoot toMany: [objectClass class]];
    OXmlElementMapper * elementMapper = [OXmlElementMapper elementClass:[objectClass class]];
    
    //
    // If the target class is an NSManagedObject, we need a special factory block to create an instance of it in a nil context;
    //
    if (objectAllocationBlock) {
        //
        // Create a special fatory for the NSManagedObject class so it can be built
        // in a nil context.
        //
        [elementMapper setFactory: (id) ^(NSString *path, OXContext *ctx) {
            return objectAllocationBlock();
        }];
    }

    for (NSString * property in [objectMapping allKeys]) {
        NSString * xpath = [objectMapping objectForKey: property];
        
        [elementMapper xpath: xpath property: property];
    }
    //
    // Lock the mapper so it does not try to infer the other attributes and objects
    //
    [elementMapper lockMapping];
    
    //
    // Create and configure the mapper
    //
    OXmlMapper * mapper = [[OXmlMapper mapper] elements: @[rootElement, elementMapper]];
    
    //
    // Create a the reader and writer
    //
    reader = [OXmlReader readerWithMapper: mapper]; 
    writer = [OXmlWriter writerWithMapper: mapper];
    
    //
    // Configure the reader and writer
    //
    reader.context.logReaderStack = NO; //'YES' -> log mapping process
    
    if (dateFormatter) {
        [reader.context.transform registerDefaultDateFormatter: dateFormatter];
        [writer.context.transform registerDefaultDateFormatter: dateFormatter];
    }    
}

@end

