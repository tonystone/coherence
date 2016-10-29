//
//  ModuleTests.swift
//  Coherence
//
//  Created by Tony Stone on 1/25/16.
//  Copyright © 2016 Tony Stone. All rights reserved.
//

import XCTest
import Coherence

class SwiftTestModule : NSObject, CCModule {
    
    static func instance () -> CCModule! {
        return SwiftTestModule()
    }
    
    func start () {}
    func stop () {}
    
    func serviceForProtocol(_ aProtocol: Protocol!) -> AnyObject! {
        return nil
    }
    
    /**
     Returns the root view controller for this module
     */
    func rootViewController () -> UIViewController! {
        return nil
    }
}

class ModuleTests: XCTestCase {

    func testModuleInstance_Swift() {
        XCTAssertNotNil(SwiftTestModule.instance());
    }
    
    func testModuleInstance_Objc () {
        XCTAssertNotNil(CCObjcTestModule.instance());
    }
    
}
