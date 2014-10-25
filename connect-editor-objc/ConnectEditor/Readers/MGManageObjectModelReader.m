//
//  MGManageObjectModelReader.m
//  MGConnectConfigurationEditor
//
//  Created by Tony Stone on 7/6/14.
//  Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//

#import "MGManageObjectModelReader.h"
#import "MGMessageLog.h"

@interface MGManageObjectModelParserDelegate : NSObject <NSXMLParserDelegate>

    - (NSManagedObjectModel *) model;

@end

@implementation MGManageObjectModelReader

    + (NSManagedObjectModel *) manageObjectModelFromURL: (NSURL *) aModelURL {

        NSURL * contentsURL = [self modelContentsURLFromModelURL: aModelURL];
        
        MGManageObjectModelParserDelegate * delegate = [[MGManageObjectModelParserDelegate alloc] init];
        
        NSXMLParser * parser = [[NSXMLParser alloc] initWithContentsOfURL: contentsURL];
        [parser setDelegate: delegate];
        
        [parser parse];
        
        return [delegate model];
    }

    + (NSURL *) modelContentsURLFromModelURL: (NSURL *) aModelURL {
        return [aModelURL URLByAppendingPathComponent: @"contents" isDirectory: NO];
    }

@end

@implementation MGManageObjectModelParserDelegate {
        NSManagedObjectModel      * model;
        NSEntityDescription       * entityDescription;
        NSAttributeDescription    * attributeDescription;
        NSRelationshipDescription * relationshipDescription;
    
        NSMutableArray            * entities;
        NSMutableArray            * properties;
    
        NSMutableDictionary       * relationshipsDistinationNames;
    
        NSMutableString           * currentStringValue;
    }

    - (NSManagedObjectModel *) model {
        return model;
    }

    - (void) parserDidStartDocument:(NSXMLParser *)parser {
        return;
    }

    - (void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
        
        if ([elementName isEqualToString: @"model"]) {
            model    = [[NSManagedObjectModel alloc] init];
            entities = [[NSMutableArray alloc] init];
            
            if ([attributeDict objectForKey: @"userDefinedModelVersionIdentifier"]) {
                [model setVersionIdentifiers: [NSSet setWithObject: [attributeDict objectForKey: @"userDefinedModelVersionIdentifier"]]];
            }
        }
    
        if ([elementName isEqualToString: @"entity"]) {
            entityDescription = [[NSEntityDescription alloc] init];
            properties        = [[NSMutableArray alloc] init];
            
            relationshipsDistinationNames = [[NSMutableDictionary alloc] init];
   
            [entityDescription setName: [attributeDict objectForKey: @"name"]];
        }
        
        if ([elementName isEqualToString: @"attribute"]) {
            attributeDescription = [[NSAttributeDescription alloc] init];
            
            [attributeDescription setName: [attributeDict objectForKey: @"name"]];
            if ([attributeDict objectForKey: @"optional"]) {
                [attributeDescription setOptional: ([[attributeDict objectForKey: @"optional"] isEqualToString: @"YES"] ? YES : NO)];
            }
            if ([attributeDict objectForKey: @"attributeType"]) {
                [attributeDescription setAttributeType: [self attributeTypeForModelType: [attributeDict objectForKey: @"attributeType"]]];
            }
        }
        
        if ([elementName isEqualToString: @"relationship"]) {
            relationshipDescription = [[NSRelationshipDescription alloc] init];
            
            [relationshipDescription setName: [attributeDict objectForKey: @"name"]];
            if ([attributeDict objectForKey: @"optional"]) {
                [relationshipDescription setOptional: ([[attributeDict objectForKey: @"optional"] isEqualToString: @"YES"] ? YES : NO)];
            }
            if ([attributeDict objectForKey: @"toMany"]) {
   
            }
            if ([attributeDict objectForKey: @"destinationEntity"]) {
                [relationshipsDistinationNames setObject: [attributeDict objectForKey: @"destinationEntity"] forKey: [relationshipDescription name]];
            }
        }
    }


   - (void) parser: (NSXMLParser *)parser didEndElement: (NSString *) elementName namespaceURI: (NSString *) namespaceURI qualifiedName: (NSString *) qName {
       
       if ([elementName isEqualToString: @"model"]) {

           // Fix up relationship destinations
           
           for (NSString * relationshipName in relationshipsDistinationNames) {
               NSString * destinationName = [relationshipsDistinationNames objectForKey: relationshipName];
               
               NSRelationshipDescription * relationship      = [[entityDescription relationshipsByName] objectForKey: relationshipName];
               NSEntityDescription       * destinationEntity = [[model entitiesByName] objectForKey: destinationName];
               
               if (destinationEntity) {
                   [relationship setDestinationEntity: destinationEntity];
               }
           }
           
           [model setEntities: entities];
       }
       
       if ([elementName isEqualToString: @"entity"]) {
           [entityDescription setProperties: properties];
           
           [entities addObject: entityDescription];
       }
       
       if ([elementName isEqualToString: @"attribute"]) {
           [properties addObject: attributeDescription];
       }
       
       if ([elementName isEqualToString: @"relationship"]) {
           [properties addObject: relationshipDescription];
       }
       
       // Note, we assume if we've gotten this far, it's a property element
       if (currentStringValue) {
           currentStringValue = nil;
       }
       
       return;
   }
   
   - (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {

       if (!currentStringValue) {
           // currentStringValue is an NSMutableString instance variable
           currentStringValue = [[NSMutableString alloc] initWithCapacity:50];
       }
       [currentStringValue appendString: string];

   }

   - (void)parser:(NSXMLParser *)parser foundIgnorableWhitespace:(NSString *)whitespaceString {
       ;
   }
   
   - (void)parserDidEndDocument:(NSXMLParser *)parser {
       return;
   }

    - (NSAttributeType) attributeTypeForModelType: (NSString *) modelType {
        if ([modelType isEqualToString: @"String"]) {
            return NSStringAttributeType;
        }
        if ([modelType isEqualToString: @"Integer 16"]) {
            return NSInteger16AttributeType;
        }
        if ([modelType isEqualToString: @"Integer 32"]) {
            return NSInteger32AttributeType;
        }
        if ([modelType isEqualToString: @"Integer 64"]) {
            return NSInteger64AttributeType;
        }
        if ([modelType isEqualToString: @"Double"]) {
            return NSDoubleAttributeType;
        }
        return NSUndefinedAttributeType;
    }

    - (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
        [[MGMessageLog instance] logError: @"Parse Error: %@", [parseError localizedDescription]];
    }

    - (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError {
        [[MGMessageLog instance] logError: @"Validation Error: %@", [validationError localizedDescription]];
    }

@end