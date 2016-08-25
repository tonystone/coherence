//
//  ConfigurationReaderTests.swift
//  Connect
//
//  Created by Tony Stone on 8/23/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import XCTest
import CoreData
@testable import Connect

class ConfigurationReaderTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testConfiguration() throws {
        let bundle = NSBundle(forClass: self.dynamicType)
        
        if let url = bundle.URLForResource("RightScale-v1", withExtension: "wadl") {
            
            let configuration = try ConfigurationReader.configuration(fromURL: url)
            
            print(configuration)
            
        } else {
            XCTFail("Failed to find test data file.")
        }
    }

}
