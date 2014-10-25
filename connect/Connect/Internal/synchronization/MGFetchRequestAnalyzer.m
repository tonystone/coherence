//
//  MGQueryAnalyzer.m
//  Connect
//
//  Created by Tony Stone on 5/28/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import "MGFetchRequestAnalyzer.h"
#import <CoreData/CoreData.h>
#import "MGRESTfulFetchRequestAnalyzer.h"

NSString * MGFetchRequestTargetPrimaryKeyValue = @"MGFetchRequestTargetPrimaryKeyValue";

#define FetchTypeToString(t) [NSString stringWithUTF8String:#t]

@implementation MGFetchRequestAnalysis

- (id) init {
    
    if ((self = [super init])) {
        analysisData = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (MGFetchType) fetchType {
    return fetchType;
}

- (id) analysisObjectForKey:(NSString *)key {
    return [analysisData objectForKey: key];
}

- (NSString *) description {    
    return [NSString stringWithFormat: @"<%@ : %p> {\r\tentity: %@\r\tfetchType: %@\r\tanalysisData: %@\r}\r", NSStringFromClass([self class]), self, entityName, [self stringForFetchType: fetchType], analysisData];
}

- (NSString *) stringForFetchType: (MGFetchType) aFetchType {
    
    switch (aFetchType) {
        case MGFetchTypeUnknown:      return FetchTypeToString(MGFetchTypeUnknown);
        case MGFetchTypeEntity:       return FetchTypeToString(MGFetchTypeEntity);
        case MGFetchTypeObject:       return FetchTypeToString(MGFetchTypeObject);
        case MGFetchTypeRelationship: return FetchTypeToString(MGFetchTypeRelationship);
    }
    return FetchTypeToString(MGFetchTypeUnknown);
}

@end

@implementation MGFetchRequestAnalyzer


- (MGFetchRequestAnalysis *)analyze:(NSFetchRequest *)fetchRequest {
    
    NSParameterAssert(fetchRequest != nil);
    NSParameterAssert([fetchRequest entity] != nil);
    
    MGFetchRequestAnalysis * analysis = [[MGFetchRequestAnalysis alloc] init];
    
    NSEntityDescription * targetEntity       = [fetchRequest entity];
    NSMutableArray      * toOneRelationships = [[NSMutableArray alloc] init];
   
    //
    // Get a list of all the toOne relationships
    //
    for (NSRelationshipDescription * relationship in [[targetEntity relationshipsByName] allValues]) {
        if (![relationship isToMany] && [relationship inverseRelationship] != nil) {
            [toOneRelationships addObject: relationship];
        }
    }
    /*
    // NSPredicate * relationshipPredicatesWithPredicate: [fetchRequest predicate] forEntity
    
    NSPredicate * entitySearchPredicate = [self entitySearchPredicateWithPredicate: [fetchRequest predicate] forKey: urnKey];
    
    analysis->fetchType  = [self analyzeEntitySearchPredicate: entitySearchPredicate entity: [fetchRequest entity]];
    analysis->entityName = [fetchRequest entityName];
    
    switch (analysis->fetchType) {
        case MGFetchTypeObject:
        case MGFetchTypeRelationship:
        {
            [analysis->analysisData setObject: entitySearchPredicate forKey: @"entitySearchPredicate"];
            [analysis->analysisData setObject: [self keyValueFromEntitySearchPredicate: entitySearchPredicate forKey: urnKey] forKey: urnKey];
            break;
        }
        case MGFetchTypeUnknown:
        case MGFetchTypeEntity:
        default:
            break;
    }
     */
    return analysis;
}

/**
 Filter the predicate to get just the part that contains
 the key fields for this fetchRequest.
 */
- (NSPredicate *) entitySearchPredicateWithPredicate: (NSPredicate *) aPredicate forKey: (NSString *) key {
    
    NSParameterAssert(key != nil);
    
    if (!aPredicate) {
        
        return nil;
        
    } else if ([aPredicate isKindOfClass: [NSCompoundPredicate class]]) {
        
        return [self predicateWithCompoundPredicate: (NSCompoundPredicate *) aPredicate forKey: key];
        
    } else if ([aPredicate isKindOfClass: [NSComparisonPredicate class]]) {
        
        return [self predicateWithComparisonPredicate: (NSComparisonPredicate *) aPredicate forKey: key];
    }
    
    return nil;
}

- (NSPredicate *) predicateWithCompoundPredicate: (NSCompoundPredicate *) compoundPredicate forKey: (NSString *) key {
    
    NSParameterAssert(compoundPredicate != nil);
    NSParameterAssert(key != nil);
    
    NSMutableArray * resultPredicates = [[NSMutableArray alloc] init];
    
    for (NSPredicate * predicate in [compoundPredicate subpredicates]) {
        NSPredicate * resultPredicate = [self entitySearchPredicateWithPredicate: predicate forKey: key];
        
        if (resultPredicate) {
            [resultPredicates addObject: resultPredicate];
        }
    }
    if ([resultPredicates count] > 1) {
        return [[NSCompoundPredicate alloc] initWithType: [compoundPredicate compoundPredicateType] subpredicates: resultPredicates];
    } else if ([resultPredicates count] == 1) {
        return [resultPredicates lastObject];
    }
    
    return nil;
}

- (NSPredicate *) predicateWithComparisonPredicate: (NSComparisonPredicate *) comparisonPredicate forKey: (NSString *) key {
    
    NSParameterAssert(comparisonPredicate != nil);
    NSParameterAssert(key != nil);
    
    NSExpression  * leftExpression = [comparisonPredicate leftExpression];
    
    if ([leftExpression expressionType] == NSKeyPathExpressionType) {
        
        //
        // Does any of our key fields appear on the left hand side?
        //
        // If so, we need to process it.
        //
        if ([[leftExpression keyPath] isEqualToString: key]) {
            
            NSExpression * rightExpression = [comparisonPredicate rightExpression];
            
            if ([rightExpression expressionType] == NSFunctionExpressionType) {
                NSExpression * operand = [rightExpression operand];
                
                id object = [operand constantValue];
                
                rightExpression = [NSExpression expressionForConstantValue: [rightExpression expressionValueWithObject: object context:nil]];
            }
            
            return [NSComparisonPredicate predicateWithLeftExpression: leftExpression
                                                      rightExpression: rightExpression
                                                             modifier: [comparisonPredicate comparisonPredicateModifier]
                                                                 type: [comparisonPredicate predicateOperatorType]
                                                              options: [comparisonPredicate options]];
        }
    }
    return nil;
}

/**
 Figure out what the user is trying to do.  What is the fetch type.
 
 */
- (MGFetchType) analyzeEntitySearchPredicate:(NSPredicate *)aPredicate entity: (NSEntityDescription *) entity {
    
    NSParameterAssert(entity != nil);
    
    if (!aPredicate) {
        
        return MGFetchTypeEntity;
        
    } else if ([aPredicate isKindOfClass: [NSCompoundPredicate class]]) {
        
        NSCompoundPredicate * compoundPredicate = (NSCompoundPredicate *)aPredicate;
        
        MGFetchType fetchType = MGFetchTypeUnknown;
        NSUInteger  count     = [[compoundPredicate subpredicates] count];
        NSUInteger  current   = 0;
        
        do {
            NSPredicate * subPredicate = [[compoundPredicate subpredicates] objectAtIndex: current];
            
            fetchType = [self analyzeEntitySearchPredicate: subPredicate entity: entity];
            
        } while (fetchType == MGFetchTypeUnknown && current < count);
        
        return fetchType;
        
    } else if ([aPredicate isKindOfClass: [NSComparisonPredicate class]]) {
        
        NSComparisonPredicate * comparisonPredicate = (NSComparisonPredicate *)aPredicate;
        NSExpression          * leftExpression      = [comparisonPredicate leftExpression];
        
        if ([leftExpression expressionType] == NSKeyPathExpressionType) {
            
            switch ([comparisonPredicate predicateOperatorType]) {
                case NSBeginsWithPredicateOperatorType: return MGFetchTypeRelationship;
                case NSEqualToPredicateOperatorType:    return MGFetchTypeObject;
                default:                                return MGFetchTypeUnknown;
            }
        }
    }
    return MGFetchTypeUnknown;
}

- (id) keyValueFromEntitySearchPredicate: (NSPredicate *) aPredicate forKey: (NSString *) key {
    
    NSParameterAssert(aPredicate != nil);
    NSParameterAssert(key != nil);
    
    id keyValue = nil;
    
    if ([aPredicate isKindOfClass: [NSCompoundPredicate class]]) {
        
        NSCompoundPredicate * compoundPredicate = (NSCompoundPredicate *)aPredicate;
        
        for (NSPredicate * subPredicate in [compoundPredicate subpredicates]) {
            
            keyValue = [self keyValueFromEntitySearchPredicate: subPredicate forKey: key];
            
            if (keyValue) {
                break;
            }
        }
    } else if ([aPredicate isKindOfClass: [NSComparisonPredicate class]]) {
        
        NSComparisonPredicate * comparisonPredicate = (NSComparisonPredicate *)aPredicate;
        NSExpression          * leftExpression      = [comparisonPredicate leftExpression];
        
        if ([leftExpression expressionType] == NSKeyPathExpressionType) {
            
            return [[comparisonPredicate rightExpression] constantValue];
        }
    }
    return keyValue;
}


@end
