//
// Created by Tony Stone on 7/10/14.
// Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGXMLNode.h"

@class MGXMLElementDefinition;

@interface MGXMLElement : MGXMLNode

    - (instancetype)initWithName:(NSString *)name qualifiedName:(NSString *)qualifiedName namespaceURI:(NSString *)namespaceURI;

    - (instancetype)initWithName:(NSString *)name qualifiedName:(NSString *)qualifiedName namespaceURI:(NSString *)namespaceURI definition:(MGXMLElementDefinition *)definition;

    + (instancetype)elementWithName:(NSString *)name qualifiedName:(NSString *)qualifiedName namespaceURI:(NSString *)namespaceURI definition:(MGXMLElementDefinition *)definition;

    + (instancetype)elementWithName:(NSString *)name qualifiedName:(NSString *)qualifiedName namespaceURI:(NSString *)namespaceURI;

    - (NSString *) elementName;
    - (NSString *) elementQualifiedName;
    - (NSString *) elementNamespaceURI;

    - (NSDictionary *) namespaces;
    - (void) addPrefix: (NSString *) prefix forNamespaceURI: (NSString *) namespaceURI;
    - (void) addNamespacesFromDictionary: (NSDictionary *) aDictionary;

    - (NSDictionary *) attributes;
    - (NSDictionary *) otherAttributes;

    - (void) addAttribute: (id) value forKey: (NSString *) key;
    - (void) addAttributesFromDictionary: (NSDictionary *) aDictionary;

    - (NSArray *) elements;
    - (NSArray *) elementsWithName: (NSString *)name;

    - (void) addElement: (MGXMLElement *) anElement;

    - (MGXMLElement *) parent;
@end
