/**
 *   CCCacheTests.m
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
#import "CCUser.h"
@import Coherence;

static NSString * const kFirstName = @"First";
static NSString * const kLastName  = @"Last";
static NSString * const kUserName = @"First Last";

@interface CCCacheTests : XCTestCase
@end

@implementation CCCacheTests {
        Cache * cache;
    }

    - (void)setUp {

        [super setUp];

        NSBundle * bundle = [NSBundle bundleForClass:[self class]];
        
        NSURL *                dataCacheModelURL = [bundle URLForResource: @"TestModel" withExtension: @"momd"];
        NSManagedObjectModel * model = [[NSManagedObjectModel alloc] initWithContentsOfURL: dataCacheModelURL];

        cache = [[Cache alloc] initWithManagedObjectModel: model persistentStoreOptions: nil];
    }

    - (void)tearDown {

        cache = nil;
        
        [super tearDown];
    }

    - (void)testConstruction {
        
        XCTAssertNotNil(cache);
    }

    - (void) testCRUD {
        NSManagedObjectContext * editContext       = [cache editContext];
        NSManagedObjectContext * mainThreadContext = [cache mainThreadContext];

        NSManagedObjectID __block * userId = nil;

        XCTAssertNoThrow([editContext performBlockAndWait:^{
            CCUser *insertedUser = [NSEntityDescription insertNewObjectForEntityForName:@"CCUser" inManagedObjectContext:editContext];
            
            [insertedUser setFirstName: kFirstName];
            [insertedUser setLastName: kLastName];
            [insertedUser setUserName: kUserName];
            
            [editContext save: nil];
            
            userId = [insertedUser objectID];
        }]);

        [mainThreadContext save: nil];
        
        CCUser __block * savedUser = nil;
        
        [mainThreadContext performBlockAndWait:^{
             savedUser = (CCUser *) [mainThreadContext objectWithID: userId];
        }];

        XCTAssertNotNil(savedUser);
        XCTAssertTrue([[savedUser firstName] isEqualToString: kFirstName]);
        XCTAssertTrue([[savedUser lastName] isEqualToString: kLastName]);
        XCTAssertTrue([[savedUser userName] isEqualToString: kUserName]);
    }

@end