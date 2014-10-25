//
//  Person.h
//  MGConnect
//
//  Created by Tony Stone on 7/3/14.
//  Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <Connect/MGConnectManagedObject.h>

@class Person;

@interface Person : MGConnectManagedObject

@property (nonatomic, retain) NSString * first;
@property (nonatomic, retain) NSString * last;
@property (nonatomic, retain) NSString * ssn;
@property (nonatomic, retain) NSSet *children;
@property (nonatomic, retain) Person *parent;
@end

@interface Person (CoreDataGeneratedAccessors)

- (void)addChildrenObject:(Person *)value;
- (void)removeChildrenObject:(Person *)value;
- (void)addChildren:(NSSet *)values;
- (void)removeChildren:(NSSet *)values;

@end
