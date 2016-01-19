/**
 *   CCConfigurationTests.m
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
@import XCTest;
@import Coherence;

static char       charPListTestValue            = 'A';
static BOOL       boolPListTestValue            = YES;

static NSInteger  integerPListTestValue         = 12345;
static NSUInteger unsignedIntegerPListTestValue = 12345;
static float      floatPListTestValue           = 12345.67;
static double     doublePListTestValue          = 12345.67;
static NSString * stringPListTestValue          = @"String test value";

static NSString * stringTestValue          = @"String test value 2";
static NSString * stringReadonlyTestValue  = @"Readonly string test value";

//
// Test configuration when developers are using a pure protocol
// for their configuration construction.
//
@protocol TestPureProtocolConfiguration <NSObject>

    @property(nonatomic, readwrite, assign) char       charProperty;
    @property(nonatomic, readwrite, assign) BOOL       boolProperty;

    @property(nonatomic, readwrite, assign) NSInteger  integerProperty;
    @property(nonatomic, readwrite, assign) NSUInteger unsignedIntegerProperty;

    @property(nonatomic, readwrite, assign) float      floatProperty;
    @property(nonatomic, readwrite, assign) double     doubleProperty;

    @property(nonatomic, readwrite, strong) NSString * stringProperty;

@end

@interface CCConfigurationTests : XCTestCase
@end

@implementation CCConfigurationTests

    - (void)testPureProtocolConfigurationConstruction {
    
        XCTAssertNotNil([CCConfiguration configurationForProtocol:@protocol(TestPureProtocolConfiguration)]);
    }

    - (void) testPureProtocolConfigurationCRUD {
        NSObject <TestPureProtocolConfiguration> * configuration = [CCConfiguration configurationForProtocol:@protocol(TestPureProtocolConfiguration)];

        // Note all values are filled with the values from the info.plist

        XCTAssertEqual       ([configuration charProperty], charPListTestValue);
        XCTAssertEqual       ([configuration boolProperty], boolPListTestValue);

        XCTAssertEqual       ([configuration integerProperty],         integerPListTestValue);
        XCTAssertEqual       ([configuration unsignedIntegerProperty], unsignedIntegerPListTestValue);

        XCTAssertEqual       ([configuration floatProperty],  floatPListTestValue);
        XCTAssertEqual       ([configuration doubleProperty], doublePListTestValue);

        XCTAssertEqualObjects([configuration stringProperty], stringPListTestValue);
    }

@end