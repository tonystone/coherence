//
//  WADLReaderTests.swift
//  Connect
//
//  Created by Tony Stone on 8/26/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import XCTest
@testable import Connect

class WADLReaderTests: XCTestCase {
    
    
    func testRead_HR_Rest() throws {
        let bundle = Bundle(for: type(of: self))
        
        if let url = bundle.url(forResource: "hr-rest", withExtension: "wadl") {
        
            let application = try WADLReader().read(contentsOfURL: url)
            
            print(application)
            
        } else {
            XCTFail("Failed to find test data file.")
        }
    }
    
    func testRead_HR_Legacy() throws {
        let bundle = Bundle(for: type(of: self))
        
        if let url = bundle.url(forResource: "hr-legacy", withExtension: "wadl") {
            
            let application = try WADLReader().read(contentsOfURL: url)
            
            print(application)
            
        } else {
            XCTFail("Failed to find test data file.")
        }
    }
    
    func testRead_RightScale_v1() throws {
        let bundle = Bundle(for: type(of: self))
        
        if let url = bundle.url(forResource: "rightscale-v1", withExtension: "wadl") {
            
            let application = try WADLReader().read(contentsOfURL: url)
                
            print(application)

        } else {
            XCTFail("Failed to find test data file.")
        }
    }
}
