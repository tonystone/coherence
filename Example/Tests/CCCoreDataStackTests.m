/**
 *   CoreDataStackTests.m
 *
 *   Copyright 2015 The Climate Corporation
 *   Copyright 2015 Tony Stone
 *
 *   Licensed under the Apache License, Version 2.0 (the "License");
 *   you may not use this file except in compliance with the License.
 *   You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 *   Unless required by applicable law or agreed to in writing, software
 *   distributed under the License is distributed on an "AS IS" BASIS,
 *   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *   See the License for the specific language governing permissions and
 *   limitations under the License.
 *
 *   Created by Tony Stone on 4/30/15.
 */
#import <XCTest/XCTest.h>

#import "Tests-Swift.h"
@import CoreData;
@import Coherence;

static NSString * const kFirstName = @"First";
static NSString * const kLastName  = @"Last";
static NSString * const kUserName = @"First Last";

@interface CCCoreDataStackTests : XCTestCase
@end

@implementation CCCoreDataStackTests {
        CoreDataStack * coreDataStack;
    }

    - (void)setUp {

        [super setUp];

        NSBundle * bundle = [NSBundle bundleForClass:[self class]];
        
        NSURL *                dataCacheModelURL = [bundle URLForResource: @"TestModel" withExtension: @"momd"];
        NSManagedObjectModel * model = [[NSManagedObjectModel alloc] initWithContentsOfURL: dataCacheModelURL];

        coreDataStack = [[CoreDataStack alloc] initWithManagedObjectModel: model];
    }

    - (void)tearDown {

        coreDataStack = nil;
        
        [super tearDown];
    }

    - (void)testConstruction {
        
        XCTAssertNotNil(coreDataStack);
    }

    - (void) testCRUD {
        NSManagedObjectContext * editContext       = [coreDataStack editContext];
        NSManagedObjectContext * mainThreadContext = [coreDataStack mainThreadContext];

        NSManagedObjectID __block * userId = nil;

        XCTAssertNoThrow([editContext performBlockAndWait:^{
            User *insertedUser = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:editContext];
            
            [insertedUser setFirstName: kFirstName];
            [insertedUser setLastName: kLastName];
            [insertedUser setUserName: kUserName];
            
            [editContext save: nil];
            
            userId = [insertedUser objectID];
        }]);

        [mainThreadContext save: nil];
        
        User __block * savedUser = nil;
        
        [mainThreadContext performBlockAndWait:^{
             savedUser = (User *) [mainThreadContext objectWithID: userId];
        }];

        XCTAssertNotNil(savedUser);
        XCTAssertTrue([[savedUser firstName] isEqualToString: kFirstName]);
        XCTAssertTrue([[savedUser lastName] isEqualToString: kLastName]);
        XCTAssertTrue([[savedUser userName] isEqualToString: kUserName]);
    }

@end