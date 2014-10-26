//
// Created by Tony Stone on 7/9/14.
// Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//

#import "MGXMLReader.h"
#import "MGXMLDocument.h"
#import "MGXMLElement.h"
#import "MGXMLCDATA.h"
#import "MGXMLComment.h"
#import "MGXMLWhitespace.h"

//
// Note: using the SAX parser so we can also run this on the iPhone
//
@interface MGWADLReaderDelegate  : NSObject <NSXMLParserDelegate>

    - (instancetype)initWithElementClassPrefixes: (NSArray *) elementClassPrefixes;
    - (MGXMLDocument *) xmlDocument;

@end

@implementation MGXMLReader {

    }

    + (MGXMLDocument *)xmlDocumentFromData:(NSData *) data {
        return [self xmlDocumentFromData: data elementClassPrefixes: nil];
    }

    + (MGXMLDocument *)xmlDocumentFromData:(NSData *) data elementClassPrefixes: (NSArray *) prefixes {
        MGWADLReaderDelegate * delegate = [[MGWADLReaderDelegate alloc] initWithElementClassPrefixes: prefixes];

        NSXMLParser * parser = [[NSXMLParser alloc] initWithData: data];
        [parser setDelegate: delegate];
        [parser setShouldProcessNamespaces: YES];
        [parser setShouldReportNamespacePrefixes: YES];
        [parser setShouldResolveExternalEntities: YES];

        [parser parse];

        return [delegate xmlDocument];
    }

    + (MGXMLDocument *)xmlDocumentFromURL:(NSURL *) fileURL {
        return [self xmlDocumentFromURL: fileURL elementClassPrefixes: nil];
    }

    + (MGXMLDocument *)xmlDocumentFromURL:(NSURL *) fileURL elementClassPrefixes: (NSArray *) prefixes  {
        return [self xmlDocumentFromData: [NSData dataWithContentsOfURL: fileURL] elementClassPrefixes: prefixes];
    }

@end

//
// Namespace Scope manager
//
@interface MGNamespaceManager : NSObject

    - (void) beginScopeForPrefix: (NSString *) prefix namespaceURI: (NSString *) namespaceURI;
    - (void)   endScopeForPrefix: (NSString *) prefix;

    - (BOOL) isPrefixInScope: (NSString *) prefix;
@end

@implementation MGWADLReaderDelegate  {
        NSMutableString      * _currentStringValue;
        NSMutableArray       * _currentNodeQueue;
        MGXMLDocument        * _document;
        NSArray              * _elementClassPrefixes;

        NSMutableDictionary  * _elementNamespaces;

        MGNamespaceManager * _namespaceManager;
    }

    - (instancetype)initWithElementClassPrefixes: (NSArray *) elementClassPrefixes {
        self = [super init];
        if (self) {
            _elementClassPrefixes = elementClassPrefixes;

            _currentStringValue   = [[NSMutableString alloc] init];
            _currentNodeQueue     = [[NSMutableArray alloc] init];

            _elementNamespaces    = [[NSMutableDictionary alloc] init];
            _namespaceManager     = [[MGNamespaceManager alloc] init];
        }
        return self;
    }

    - (MGXMLDocument *)xmlDocument {
        return _document;
    }

    - (void) parserDidStartDocument:(NSXMLParser *)parser {
        _document = [[MGXMLDocument alloc] init];
        [_currentNodeQueue addObject:_document];
    }

    - (void)parser:(NSXMLParser *)parser didStartMappingPrefix:(NSString *)prefix toURI:(NSString *)namespaceURI {
        [_namespaceManager beginScopeForPrefix: prefix namespaceURI: namespaceURI];

        [_elementNamespaces setObject: namespaceURI forKey: prefix];
    }

    - (void)parser:(NSXMLParser *)parser didEndMappingPrefix:(NSString *)prefix {
        [_namespaceManager endScopeForPrefix: prefix];
    }

    - (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
       // NSLog(@"Start \"%@\"...", qName);

        Class elementClass = [MGXMLElement class];

        if (_elementClassPrefixes) {
            for (NSString * classPrefix in _elementClassPrefixes) {
                Class classWithPrefix = NSClassFromString( [classPrefix stringByAppendingString: [elementName capitalizedString]]);

                if (classWithPrefix != NULL) {
                    if ([classWithPrefix isSubclassOfClass:[MGXMLElement class]]) {
                        elementClass = classWithPrefix;
                        break;
                    }
                }
            }
        }

        MGXMLElement * element = [(MGXMLElement *)[elementClass alloc] initWithName: elementName qualifiedName: qName namespaceURI: namespaceURI];
        [element addNamespacesFromDictionary: _elementNamespaces];
        [_elementNamespaces removeAllObjects];  // Clear it for the next element
        [element addAttributesFromDictionary: attributeDict];

        [_currentNodeQueue addObject:element];
    }


    - (void) parser: (NSXMLParser *)parser didEndElement: (NSString *) elementName namespaceURI: (NSString *) namespaceURI qualifiedName: (NSString *) qName {
       // NSLog(@"End \"%@\".", qName);
        MGXMLElement * currentElement = [_currentNodeQueue lastObject];
        [_currentNodeQueue removeLastObject];

        MGXMLNode * parentNode =  [_currentNodeQueue lastObject];

        [parentNode addChild: currentElement];
    }

    - (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock {
        [[_currentNodeQueue lastObject] addChild: [MGXMLCDATA cdataWithData: CDATABlock]];
    }

    - (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {

        if (!_currentStringValue) {
            // currentStringValue is an NSMutableString instance variable
            _currentStringValue = [[NSMutableString alloc] initWithCapacity:50];
        }
        [_currentStringValue appendString:string];
    }

    - (void)parser:(NSXMLParser *)parser foundComment:(NSString *)comment {
        [[_currentNodeQueue lastObject] addChild: [MGXMLComment commentWithText: comment]];
    }

    - (void)parser:(NSXMLParser *)parser foundIgnorableWhitespace:(NSString *)whitespaceString {
        [[_currentNodeQueue lastObject] addChild: [MGXMLWhitespace whitespaceWithText: whitespaceString]];
    }

    - (void)parserDidEndDocument:(NSXMLParser *)parser {
        return;
    }

    - (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
        NSLog(@"Parse Error: %@", [parseError localizedDescription]);
    }

    - (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError {
        NSLog(@"Validation Error: %@", [validationError localizedDescription]);
    }

@end


@implementation MGNamespaceManager {
        NSMutableDictionary  * _inScopeNamespaces;
    }

    - (instancetype)init {
        self = [super init];
        if (self) {
            _inScopeNamespaces    = [[NSMutableDictionary alloc] init];
        }
        return self;
    }

    - (void)beginScopeForPrefix:(NSString *)prefix namespaceURI:(NSString *)namespaceURI {

        // Add the prefix to the inScope dictionary
        // and push the uri it's currently defined as onto the stack.
        NSMutableArray * namespaceStack = [_inScopeNamespaces objectForKey: prefix];
        if (!namespaceStack) {
            namespaceStack = [[NSMutableArray alloc] init];

            [_inScopeNamespaces setObject:namespaceStack forKey:prefix];
        }
        [namespaceStack addObject:namespaceURI];

        NSLog(@"Prefix \"%@\" for namespace \"%@\" in scope...", prefix, namespaceURI);
    }

    - (void)endScopeForPrefix:(NSString *)prefix {

        NSMutableArray * namespaceStack = [_inScopeNamespaces objectForKey: prefix];
        if (namespaceStack) {
            [namespaceStack removeLastObject];

            if ([namespaceStack count] == 0) {
                [_inScopeNamespaces removeObjectForKey: prefix];
            }
        }
        NSLog(@"Prefix \"%@\" out of scope...", prefix);
    }

    - (BOOL)isPrefixInScope:(NSString *)prefix {
        return [_inScopeNamespaces objectForKey: prefix] != nil;
    }
@end