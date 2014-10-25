//
//  Employee.h
//  Connect
//
//  Created by Tony Stone on 9/7/14.
//  Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Person.h"

@class Company, Role;

@interface Employee : Person

@property (nonatomic) int32_t employeeNumber;
@property (nonatomic) double salary;
@property (nonatomic, retain) Company *company;
@property (nonatomic, retain) NSSet *roles;
@end

@interface Employee (CoreDataGeneratedAccessors)

- (void)addRolesObject:(Role *)value;
- (void)removeRolesObject:(Role *)value;
- (void)addRoles:(NSSet *)values;
- (void)removeRoles:(NSSet *)values;

@end
