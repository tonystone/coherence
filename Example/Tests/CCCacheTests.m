//
// Created by Tony Stone on 4/30/15.
// Copyright (c) 2015 Tony Stone. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Coherence/Coherence.h>
#import "CCUser.h"

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
        
        cache = [[CCCache alloc] initWithIdentifier: @"TestModule" managedObjectModel: model];
    }

    - (void)tearDown {

        // Put teardown code here. This method is called after the invocation of each test method in the class.
        [super tearDown];
    }

    - (void)testConstruction {
        
        XCTAssertNotNil(cache);
    }

    - (void) testCRUD {
         NSManagedObjectContext * context = [cache editContext];

        CCUser * user = [NSEntityDescription insertNewObjectForEntityForName: @"CCUser" inManagedObjectContext:  context];

        [user setFirstName: @"First"];
        [user setLastName:  @"Last"];
        [user setUserName:  @"lastfirst"];

        XCTAssertNoThrow([context save: nil]);
    }

@end