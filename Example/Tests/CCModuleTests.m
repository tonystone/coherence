//
//  CCModuleTests.m
//  Coherence
//
//  Created by Tony Stone on 1/18/16.
//  Copyright © 2016 Tony Stone. All rights reserved.
//
@import XCTest;
@import Coherence;

@interface TestModule : NSObject <CCModule>
@end

@implementation TestModule

    + (id <CCModule>) instance {
        return [[self alloc] init];
    }

    - (void) start {}
    - (void) stop {}

    - (id <CCResourceService>) serviceForProtocol: (Protocol *) aProtocol {
        return nil;
    }

    - (UIViewController *) rootViewController {
        return nil;
    }
@end


@interface CCModuleTests : XCTestCase
@end

@implementation CCModuleTests

    - (void) moduleTestInstance {
        id <CCModule> module = [TestModule instance];
        
        XCTAssertNotNil(module);
    }

@end
