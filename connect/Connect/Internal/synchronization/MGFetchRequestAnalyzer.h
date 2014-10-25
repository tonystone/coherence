//
//  MGQueryAnalyzer.h
//  Connect
//
//  Created by Tony Stone on 5/28/13.
//  Copyright (c) 2013 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSFetchRequest;

extern NSString * MGFetchRequestTargetPrimaryKeyValue;

typedef enum {
    MGFetchTypeUnknown      = 0,
    MGFetchTypeEntity       = 1,
    MGFetchTypeObject       = 2,
    MGFetchTypeRelationship = 3,
} MGFetchType;

@interface MGFetchRequestAnalysis : NSObject  {
@package
    MGFetchType fetchType;
    NSString   * entityName;
    NSMutableDictionary * analysisData;
}

- (MGFetchType) fetchType;
- (id) analysisObjectForKey: (NSString *)key;

@end

/*
 
    Search entity:
 
        Company
 
        Critieria:
 
            Is a root entity
            No predicate
    
    Search for children of an object:
 
        Employee
 
        Criteria:
 
            self.company == object
            self.company == objectID
 
            self.company == object AND self.person == object
 
    Search for object:
 
        Employee
 
        Critieria:
 
            
 
 */

@interface MGFetchRequestAnalyzer : NSObject

//
// Build the analysis object
//
- (MGFetchRequestAnalysis *) analyze: (NSFetchRequest *) fetchRequest;

@end
