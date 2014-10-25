//
//  MGXPathObjectMapper.m
//  MGConnect
//
//  Created by Tony Stone on 4/27/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGXPathV1ObjectMapper.h"
#import "MGRuntimeException.h"
#import "MGTraceLog.h"

#import <libxml/tree.h>
#import <libxml/xpath.h>
#import <libxml/xpathInternals.h>

void mgDateTime (xmlXPathParserContextPtr ctxt, int nargs);

@implementation MGXPathV1ObjectMapper {
    NSString      * objectRoot;
    NSDictionary  * objectMapping;

    id (^objectAllocationBlock) (void);
}

+ (void)initialize {
    
    if (self == [MGXPathV1ObjectMapper class]) {
        //
        // Initialize libXML
        //
        xmlInitParser();
    }
}

- (id) initWithObjectClass: (Class) anObjectClass objectAllocationBlock: (id (^)(void)) objectAllocationBlockOrNil objectMapping: (NSDictionary *) anObjectMapping objectRoot: (NSString *) anObjectRootOrNil dateFormatter: (NSDateFormatter *) dateFormatterOrNil {
    
    //NSParameterAssert(anObjectClass   != nil);
    NSParameterAssert(anObjectMapping != nil);
    
    if ((self = [super init])) {
        if (!anObjectRootOrNil) {
            anObjectRootOrNil = @"/";
        }
        objectRoot            = anObjectRootOrNil;
        objectMapping         = anObjectMapping;
        objectAllocationBlock = objectAllocationBlockOrNil;
    }
    return self;
}

- (NSArray *) map: (NSData *)data {
    
    NSParameterAssert(data != nil);
    
    NSMutableArray * results = [[NSMutableArray alloc] init];
    
    xmlDocPtr doc = xmlReadMemory(data.bytes, data.length, (const char *) "", (const char *) NULL, (XML_PARSE_RECOVER | XML_PARSE_NOERROR | XML_PARSE_NOWARNING | XML_PARSE_NONET));
    if (doc == NULL) {
        @throw [MGRuntimeException exceptionWithName: @"Runtime Exception" reason: @"XML Parsing error: failed to parse document" userInfo: nil];
    }
    
    xmlXPathContextPtr xPathCtx = xmlXPathNewContext(doc);
    if (xPathCtx == NULL) {
        xmlFreeDoc(doc);
        
        @throw [MGRuntimeException exceptionWithName: @"Runtime Exception" reason: @"XML Parsing error: failed to get an xpath context" userInfo: nil];
    }
    
    //
    // Register extension functions
    //
    // NOTE: For now these are registered in the mg and NULL name space so you can use them with or without a prefix
    //
    xmlXPathRegisterNs    (xPathCtx, (const xmlChar *) "mg", (const xmlChar *) "http://www.mobilegridinc.com/ns/mg");
    xmlXPathRegisterFuncNS(xPathCtx, (const xmlChar *) "dateTime", (const xmlChar *) "http://www.mobilegridinc.com/ns/ns", mgDateTime);
    xmlXPathRegisterFuncNS(xPathCtx, (const xmlChar *) "dateTime", (const xmlChar *) NULL, mgDateTime);
    
    //
    // Find the root element and start iterating over them
    //
    xmlXPathObjectPtr xPathObj = xmlXPathEvalExpression((const xmlChar *) [objectRoot UTF8String], xPathCtx);
    if (xPathObj == NULL) {
        xmlXPathFreeContext(xPathCtx);
        xmlFreeDoc(doc);
        
        @throw [MGRuntimeException exceptionWithName: @"Runtime Exception" reason: @"No objectRoot found" userInfo: nil];
    }
    
    //
    // Note: we wrap this in a try block so
    //       that if our sub routines throw
    //       an exception, we can clean up
    //       in the finally.
    //
    @try {
        //
        // If this is a node set
        //
        if (xPathObj->type == XPATH_NODESET) {
            xmlNodeSetPtr nodes = xPathObj->nodesetval;
            
            int size = (nodes) ? nodes->nodeNr : 0;
            
            for(int i = 0; i < size; ++i) {
                assert(nodes->nodeTab[i]);
                
                id object = [self mapNewObject: nodes->nodeTab[i] context: xPathCtx];
                
                if (object) {
                    [results addObject: object];
                }
            }
        }
    }
    @finally {
        xmlXPathFreeObject(xPathObj);
        xmlXPathFreeContext(xPathCtx);
        xmlFreeDoc(doc);
    }

    return results;
}

- (NSData *) reverseMap:(NSArray *)objects {
    return nil;
}

#pragma mark - Private methods

- (id) allocateNewObject {
    if (objectAllocationBlock) {
        return objectAllocationBlock();
    }
    return [[NSMutableDictionary alloc] init];
}

- (id) mapNewObject: (xmlNodePtr) node context: (xmlXPathContextPtr) xPathCtx {
    
    NSParameterAssert(node != NULL);
    
    xmlNodePtr savedContextNode = xPathCtx->node;
    
    //
    // Set the contexts search node
    // to the current node so the search only
    // happens within this node.
    //
    xPathCtx->node = node;
    
    NSMutableDictionary * newObject = [self allocateNewObject];
    
    for (NSString * attribute in objectMapping) {
        NSString * attributeXPath = [objectMapping objectForKey: attribute];
        
        xmlXPathObjectPtr xPathObject = xmlXPathEvalExpression((const xmlChar *) [attributeXPath UTF8String], xPathCtx);
        
        if (xPathObject != NULL) {
            id value = [self xPathObjectValue: xPathObject];

            if (value) {
                [newObject setValue: value forKey: attribute];
            }
        }
    }
    
    //
    // Restore the context back to the original position
    //
    xPathCtx->node = savedContextNode;
    
    return newObject;
}

- (id) xPathObjectValue: (xmlXPathObjectPtr) xPathObject {
    id value = nil;
    
    switch (xPathObject->type) {
        case XPATH_NODESET:
        {
            xmlNodeSetPtr nodeSet = xPathObject->nodesetval;
            
            if (nodeSet && nodeSet->nodeNr > 0) {
                
                xmlNodePtr node = nodeSet->nodeTab[0];
                
                if (node->children && node->children->content) {
                    value = [NSString stringWithCString: (char *) node->children->content encoding: NSUTF8StringEncoding];
                }
            }
            break;
        }
        case XPATH_NUMBER:
        {
            value = [NSNumber numberWithDouble: xPathObject->floatval];
            break;
        }
        case XPATH_BOOLEAN:
        {
            value = [NSNumber numberWithBool: xPathObject->boolval];
            break;
        }
        case XPATH_STRING:
        {
            if (xPathObject->stringval) {
                value = [NSString stringWithCString: (char *) xPathObject->stringval encoding: NSUTF8StringEncoding];
            }
            break;
        }
        case XPATH_USERS:
        {
            if (xPathObject->user) {
                value = CFBridgingRelease(xPathObject->user);
            }
            break;
        }
        case XPATH_UNDEFINED:
        case XPATH_LOCATIONSET:
        case XPATH_POINT:
        case XPATH_RANGE:
        default:
            break;
    }
    
    return value;
}

@end

void mgDateTime (xmlXPathParserContextPtr ctxt, int nargs) {

    static NSDateFormatter * formatter;
    
    if (nargs != 2) {
        printf("Invalid number of arguments to dateTime() function");
    }
    xmlChar * format = xmlXPathPopString(ctxt);
    xmlChar * value  = xmlXPathPopString(ctxt);
    
    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
    }
    
    [formatter setDateFormat: [NSString stringWithCString: (const char *) format encoding: NSUTF8StringEncoding]];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    NSDate * date = [formatter dateFromString: [NSString stringWithCString: (const char *) value encoding: NSUTF8StringEncoding]];
    
    xmlXPathReturnExternal(ctxt, (void *) CFBridgingRetain(date));
}