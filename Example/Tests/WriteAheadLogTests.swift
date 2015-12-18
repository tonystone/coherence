//
//  WriteAheadLogTests.swift
//  Coherence
//
//  Created by Tony Stone on 12/11/15.
//  Copyright © 2015 Tony Stone. All rights reserved.
//

import XCTest
@testable import Coherence

class WriteAheadLogTests: XCTestCase {
    
    func testExample() {
        let cachePath = NSSearchPathForDirectoriesInDomains(.CachesDirectory,.UserDomainMask, true)[0] as String
        
        do {
            _ = try  WriteAheadLog(identifier: "A23B34", path: cachePath)
        } catch {
            
        }
    }
    
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measureBlock {
//            // Put the code you want to measure the time of here.
//        }
//    }
    
}
