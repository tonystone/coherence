//
//  WADLReaderTests.swift
//  Connect
//
//  Created by Tony Stone on 8/26/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import XCTest
@testable import Connect

class XMLReaderTests: XCTestCase {
    
    
    func testParser() throws {
        let bundle = Bundle(for: type(of: self))
        
        if let url = bundle.url(forResource: "hr-rest", withExtension: "wadl") {
            
            let document = try XMLReader.document(contentsOfURL: url)
            
            print(document)
            
        } else {
            XCTFail("Failed to find test data file.")
        }
    }
}
