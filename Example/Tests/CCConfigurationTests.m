//
// Created by Tony Stone on 4/30/15.
// Copyright (c) 2015 Tony Stone. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Coherence/Coherence.h>
#import "CCConfiguration.h"

static char       charPListTestValue            = 'A';
static BOOL       boolPListTestValue            = YES;

static NSInteger  integerPListTestValue         = 12345;
static NSUInteger unsignedIntegerPListTestValue = 12345;
static float      floatPListTestValue           = 12345.67;
static double     doublePListTestValue          = 12345.67;
static NSString * stringPListTestValue          = @"String test value";

static char       charTestValue            = 'b';
static BOOL       boolTestValue            = NO;

static NSInteger  integerTestValue         = 54321;
static NSUInteger unsignedIntegerTestValue = 54321;
static float      floatTestValue           = 54321.67;
static double     doubleTestValue          = 54321.67;
static NSString * stringTestValue          = @"String test value 2";
static NSString * stringReadonlyTestValue  = @"Readonly string test value";
static int        intReadonlyTestValue     = true;
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

//
// Test configuration when developers are using a subclass
// of CCConfiguration for their configuration using default values.
//
@protocol TestSubClassConfiguration <NSObject>

    @property(nonatomic, readwrite, assign) char       charProperty;
    @property(nonatomic, readwrite, assign) BOOL       boolProperty;

    @property(nonatomic, readwrite, assign) NSInteger  integerProperty;
    @property(nonatomic, readwrite, assign) NSUInteger unsignedIntegerProperty;

    @property(nonatomic, readwrite, assign) float      floatProperty;
    @property(nonatomic, readwrite, assign) double     doubleProperty;

    @property(nonatomic, readwrite, strong) NSString * stringProperty;

    @property(nonatomic, readonly, strong)            NSString * stringPropertyReadonly;
    @property(getter=isIntPropertyReadonly, readonly) int        intPropertyReadonly;

@end

@interface TestSubClassConfiguration : CCConfiguration <CCConfiguration>
@end
@implementation TestSubClassConfiguration

//    @synthesize stringProperty, stringPropertyReadonly, unsignedIntegerProperty, boolProperty, doubleProperty, intReadOnlyGetter;

    - (NSDictionary *) defaults {
        return @{
                @"stringPropertyReadonly": stringReadonlyTestValue,
                @"intPropertyReadonly": @(intReadonlyTestValue)
        };

    }
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

    - (void)testSubclassConfigurationConstruction {

        XCTAssertNotNil([TestSubClassConfiguration configurationForProtocol:@protocol(TestSubClassConfiguration)]);
    }

    - (void) testSubclassConfigurationCRUD {

        NSObject <TestSubClassConfiguration> * configuration = [TestSubClassConfiguration configurationForProtocol:@protocol(TestSubClassConfiguration)];

        [configuration setCharProperty: charTestValue];
        [configuration setBoolProperty: boolTestValue];

        [configuration setIntegerProperty: integerTestValue];
        [configuration setUnsignedIntegerProperty: unsignedIntegerTestValue];

        [configuration setFloatProperty: floatTestValue];
        [configuration setDoubleProperty: doubleTestValue];

        [configuration setStringProperty: stringTestValue];

        XCTAssertEqual       ([configuration charProperty], charTestValue);
        XCTAssertEqual       ([configuration boolProperty], boolTestValue);

        XCTAssertEqual       ([configuration integerProperty],         integerTestValue);
        XCTAssertEqual       ([configuration unsignedIntegerProperty], unsignedIntegerTestValue);

        XCTAssertEqual       ([configuration floatProperty],  floatTestValue);
        XCTAssertEqual       ([configuration doubleProperty], doubleTestValue);

        XCTAssertEqualObjects([configuration stringProperty], stringTestValue);

        XCTAssertEqualObjects([configuration stringPropertyReadonly],  stringReadonlyTestValue);
        XCTAssertEqual       ([configuration isIntPropertyReadonly],   intReadonlyTestValue);
    }

@end