//
//  CCModuleTests.m
//  Coherence
//
//  Created by Tony Stone on 1/18/16.
//  Copyright © 2016 Tony Stone. All rights reserved.
//
@import XCTest;
@import Coherence;
#import "CCObjcTestModule.h"

@interface CCModuleTests : XCTestCase
@end

@implementation CCModuleTests

    - (void) testModuleInstance {
        id <CCModule> module = [CCObjcTestModule instance];
        
        XCTAssertNotNil(module);
    }

@end
