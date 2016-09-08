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
        
        if let url = bundle.url(forResource: "hr-rest", withExtension: "wadl"),
           let stream = InputStream(url: url) {
            
            let application = try WADLReader().read(stream: stream)
            
            print(application.description)
            
        } else {
            XCTFail("Failed to find test data file.")
        }
    }
    
    func testRead_HR_Legacy() throws {
        let bundle = Bundle(for: type(of: self))
        
        if let url = bundle.url(forResource: "hr-legacy", withExtension: "wadl"),
           let stream = InputStream(url: url) {
            
            let application = try WADLReader().read(stream: stream)
            
            print(application.description)
        } else {
            XCTFail("Failed to find test data file.")
        }
    }
    
    func testRead_RightScale_v1() throws {
        let bundle = Bundle(for: type(of: self))
        
        if let url = bundle.url(forResource: "rightscale-v1", withExtension: "wadl"),
           let stream = InputStream(url: url) {
            
            let application = try WADLReader().read(stream: stream)
            
            print(application.description)

        } else {
            XCTFail("Failed to find test data file.")
        }
    }
    
    func testRead_ResourceType_Invalid_Param_Style () throws {
        let string = "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>" +
            "<application xmlns=\"http://wadl.dev.java.net/2009/02\">" +
            "   <resource_type id=\"test_type\">" +
            "   </resource_type>" +
            "</application>"
        
        if let input = string.data(using: String.Encoding.utf8) {
        
            let inputStream = InputStream(data: input)
        
            do {
                let application = try WADLReader().read(stream: inputStream )
        
                print(application.description)
            } catch {
                // Success
            }
        } else {
            XCTFail("Failed to find test data file.")
        }


    }
}
