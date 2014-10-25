//
//  Company.h
//  MGConnect
//
//  Created by Tony Stone on 7/3/14.
//  Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <Connect/MGConnectManagedObject.h>

@class Employee;

@interface Company : MGConnectManagedObject

@property (nonatomic, retain) NSString * ein;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSOrderedSet *employees;
@end

@interface Company (CoreDataGeneratedAccessors)

- (void)insertObject:(Employee *)value inEmployeesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromEmployeesAtIndex:(NSUInteger)idx;
- (void)insertEmployees:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeEmployeesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInEmployeesAtIndex:(NSUInteger)idx withObject:(Employee *)value;
- (void)replaceEmployeesAtIndexes:(NSIndexSet *)indexes withEmployees:(NSArray *)values;
- (void)addEmployeesObject:(Employee *)value;
- (void)removeEmployeesObject:(Employee *)value;
- (void)addEmployees:(NSOrderedSet *)values;
- (void)removeEmployees:(NSOrderedSet *)values;
@end
