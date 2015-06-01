//
// Created by Tony Stone on 4/30/15.
// Copyright (c) 2015 Tony Stone. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Coherence/Coherence.h>
#import "CCUser.h"

static NSString * const kFirstName = @"First";
static NSString * const kLastName  = @"Last";
static NSString * const kUserName = @"First Last";

@interface CCCacheTests : XCTestCase
@end

@implementation CCCacheTests {
        CCCache *cache;
    }

    - (void)setUp {

        [super setUp];

        NSBundle * bundle = [NSBundle bundleForClass:[self class]];
        
        NSURL *                dataCacheModelURL = [bundle URLForResource: @"TestModel" withExtension: @"momd"];
        NSManagedObjectModel * model = [[NSManagedObjectModel alloc] initWithContentsOfURL: dataCacheModelURL];
        
        cache = [[CCCache alloc] initWithManagedObjectModel: model];
    }

    - (void)tearDown {

        // Put teardown code here. This method is called after the invocation of each test method in the class.
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

        CCUser __block * savedUser = nil;
        
        [mainThreadContext performBlockAndWait:^{
             savedUser = (CCUser *) [mainThreadContext objectWithID: userId];
        }];

        XCTAssertNotNil(savedUser);
        XCTAssertEqual([savedUser firstName], kFirstName);
        XCTAssertEqual([savedUser lastName],  kLastName);
        XCTAssertEqual([savedUser userName],  kUserName);
    }

@end