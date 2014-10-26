//
//  Connect_Common_Tests.m
//  Connect CommonTests
//
//  Created by Tony Stone on 10/25/14.
//  Copyright (c) 2014 Mobile Grid, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <Connect-Common/Version.h>

@interface Connect_Common_Tests : XCTestCase

@end

@implementation Connect_Common_Tests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
