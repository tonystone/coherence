//
// Created by Tony Stone on 7/10/14.
// Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//

#import "MGXMLElement.h"
#import "MGXMLElementDefinition.h"

@interface MGXMLElement () {
        NSString                * _name;
        NSString                * _qualifiedName;
        NSString                * _namespaceURI;
        NSMutableDictionary     * _namespaces;
        NSMutableDictionary     * _attributes;
        NSMutableDictionary     * _otherAttributes;
        NSMutableArray          * _elementArrays;
        MGXMLElementDefinition  * _definition;

        MGXMLElement            * _parent;
    }
@end

@implementation MGXMLElement

    static MGXMLElementDefinition * defaultDefinition = nil;

    + (void) load {
        defaultDefinition = [[MGXMLElementDefinition alloc] initWithAttributeNames: @[@"##any"] elementNames: @[@"##any"]];
    }

    - (void) commonMGXMLElementInitWithName:(NSString *)name qualifiedName:(NSString *)qualifiedName namespaceURI:(NSString *)namespaceURI definition:(MGXMLElementDefinition *)definition {
        _name            = name;
        _qualifiedName   = qualifiedName;
        _namespaceURI    = namespaceURI;
        _definition      = definition;

        _namespaces      = [[NSMutableDictionary alloc] init];
        _attributes      = [[NSMutableDictionary alloc] init];
        _elementArrays   = [[NSMutableArray alloc] initWithCapacity: [[_definition elementNames] count]];

        if ([_definition allowOtherAttributes] && ![_definition allowAnyAttributes]) {
            _otherAttributes = [[NSMutableDictionary alloc] init];
        }

        // Initialize the internal element structures for the definition.
        for (int i = 0; i < [[_definition elementNames] count]; i++) {
            [_elementArrays addObject:[[NSMutableArray alloc] init]];
        }
    }

    - (instancetype)initWithName:(NSString *)name qualifiedName:(NSString *)qualifiedName namespaceURI:(NSString *)namespaceURI definition:(MGXMLElementDefinition *)definition {
        self = [super init];
        if (self) {
            [self commonMGXMLElementInitWithName: name  qualifiedName: qualifiedName namespaceURI: namespaceURI definition: definition];
        }
        return self;
    }

    + (instancetype)elementWithName:(NSString *)name qualifiedName:(NSString *)qualifiedName namespaceURI:(NSString *)namespaceURI definition:(MGXMLElementDefinition *)definition {
        return [[self alloc] initWithName:name qualifiedName:qualifiedName namespaceURI:namespaceURI definition:definition];
    }

    - (instancetype)initWithName:(NSString *)name qualifiedName:(NSString *)qualifiedName namespaceURI:(NSString *)namespaceURI {
        self = [super init];
        if (self) {
            [self commonMGXMLElementInitWithName: name  qualifiedName: qualifiedName namespaceURI: namespaceURI definition: defaultDefinition];
        }
        return self;
    }

    + (instancetype)elementWithName:(NSString *)name qualifiedName:(NSString *)qualifiedName namespaceURI:(NSString *)namespaceURI {
        return [[self alloc] initWithName:name qualifiedName:qualifiedName namespaceURI:namespaceURI];
    }

    - (NSString *)elementName {
        return _name;
    }

    - (NSString *)elementQualifiedName {
        return _qualifiedName;
    }

    - (NSString *)elementNamespaceURI {
        return _namespaceURI;
    }

    - (NSDictionary *) namespaces {
        return _namespaces;
    }

    - (void) addPrefix: (NSString *) prefix forNamespaceURI: (NSString *) namespaceURI {
        [_namespaces setObject: namespaceURI forKey: prefix];
    }

    - (void)addNamespacesFromDictionary:(NSDictionary *)aDictionary {
        [_namespaces addEntriesFromDictionary: aDictionary];
    }

    - (NSDictionary *)attributes {
        return _attributes;
    }

    - (NSDictionary *) otherAttributes {
        return _otherAttributes;
    }

    - (void)addAttribute:(id)value forKey:(NSString *)key {

        if ([_definition allowAnyAttributes] || [[_definition attributeNames] containsObject: key]) {
            [_attributes setObject: value forKey: key];

        } else {

            if ([_definition allowOtherAttributes]) {
                [_otherAttributes setObject: value forKey: key];
            }
        }
    }

    - (void)addAttributesFromDictionary:(NSDictionary *)aDictionary {

        for (NSString * key in aDictionary) {
            [self addAttribute: [aDictionary objectForKey: key] forKey: key];
        }
    }

    - (void)addChild:(MGXMLNode *)child {
        [super addChild:child];

        if ([child isKindOfClass: [MGXMLElement class]]) {
            [self addElement: (MGXMLElement *) child];
        }
    }

    - (void)addElement:(MGXMLElement *)anElement {

    #warning FAILING to always return the same string, need to change this to manudal do an isEqualToString or add a method to the defition to do the same and return the index of the element.
        NSUInteger index = [_definition indexOfElementForName:[anElement elementName]];

        NSMutableArray * elements = nil;

         if (index == NSNotFound) {
            if ([_definition allowAnyElements]) {
                index = [_definition indexOfElementForName: @"##any"];

                elements = [_elementArrays objectAtIndex: index];

            } else if ([_definition allowOtherElements]) {
                index = [_definition indexOfElementForName: @"##other"];

                elements = [_elementArrays objectAtIndex: index];
            }
        } else {
            elements = [_elementArrays objectAtIndex:index];
        }

        if (elements) {
            anElement->_parent = self;
            [elements addObject: anElement];
        }
    }

    - (MGXMLElement *)parent {
        return _parent;
    }


    - (NSArray *) elements {
        return [_elementArrays valueForKeyPath: @"@unionOfArrays.self"];
    }

    - (NSArray *)elementsWithName: (NSString *)name {

        NSUInteger index = [_definition indexOfElementForName: name];

        if (index != NSNotFound) {
            return [_elementArrays objectAtIndex:index];
        }

        return nil;
    }

    - (NSString *)xmlString:(NSUInteger)level {
        NSMutableString * xmlString = [[NSMutableString alloc] initWithFormat: @"%@%@%@", [@"" stringByPaddingToLength: level withString:@"\t" startingAtIndex:0], @"<", _qualifiedName];

        NSString * namespacePadding = [@"" stringByPaddingToLength: level withString:@"\t" startingAtIndex:0];
        namespacePadding = [namespacePadding stringByAppendingString: [@"" stringByPaddingToLength: (1 + [_name length]) withString:@" " startingAtIndex:0]];
        int namespaceCount = 0;

        for (NSString * key in _namespaces) {
            if (namespaceCount > 0) {
                [xmlString appendFormat: @"\r\n%@", namespacePadding];
            }

            NSString * prefix = @"xmlns";

            if ([key length] > 0)
                prefix = [[prefix stringByAppendingString:@":"] stringByAppendingString: key];

            [xmlString appendFormat: @" %@=\"%@\"", prefix, [_namespaces objectForKey: key]];

            namespaceCount++;
        }

        for (NSString * key in _attributes) {
            [xmlString appendFormat: @" %@=\"%@\"", key, [_attributes objectForKey: key]];
        }

        if ([[self children] count] > 0) {
            [xmlString appendString: @">"];

            for (MGXMLNode * node in [self children] ) {
                [xmlString appendFormat: @"\r\n%@", [node xmlString: level+1]];
            }

            [xmlString appendFormat: @"\r\n%@%@%@%@", [@"" stringByPaddingToLength: level withString:@"\t" startingAtIndex:0], @"</", _qualifiedName, @">"];
        } else {
            [xmlString appendString: @"/>"];
        }
        return xmlString;
    }

@end