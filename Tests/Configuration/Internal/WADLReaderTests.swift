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
            
            print(application.description)
            
        } else {
            XCTFail("Failed to find test data file.")
        }
    }
    
    func testRead_HR_Legacy() throws {
        let bundle = Bundle(for: type(of: self))
        
        if let url = bundle.url(forResource: "hr-legacy", withExtension: "wadl") {
            
            let application = try WADLReader().read(contentsOfURL: url)
            
            print(application.description)
        } else {
            XCTFail("Failed to find test data file.")
        }
    }
    
    func testRead_RightScale_v1() throws {
        let bundle = Bundle(for: type(of: self))
        
        if let url = bundle.url(forResource: "rightscale-v1", withExtension: "wadl") {
            
            let application = try WADLReader().read(contentsOfURL: url)
            
            print(application.description)

        } else {
            XCTFail("Failed to find test data file.")
        }
    }
    
    
    // Internal printing functions
    func describe(application: WADLApplication) {
        
        for resources in application.resources {
            
            for resource in resources.resources {
                describe(resource: resource, level: 0)
            }
        }
    }
    
    func describe(resource: WADLResource, level: Int) {
        
        print("\r" + String(repeating: "\t", count: level) + "\(resource.templatedURI)\r")
        
        if resource.params.count > 0 {
            print(String(repeating: "\t", count: level) + "Params:\n")
            for param in resource.params {
                print(param.description)
            }
        }
        
        print(String(repeating: "\t", count: level) + "Methods:\n")
        for method in resource.methods {
            print(method.description)
        }
        
        for resource in resource.resources {
            describe(resource: resource, level: level + 1)
        }
    }
    
    func describe(request: WADLRequest, level: Int) {

        print("\(request.description)")
    }
    
}
