//
//  OpenAPIReaderTests.swift
//  Connect
//
//  Created by Tony Stone on 9/13/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import XCTest
@testable import Connect

class OpenAPIReaderTests: XCTestCase {
    
    func testRead_HR_Rest() {
        let bundle = Bundle(for: type(of: self))
        
        if let url = bundle.url(forResource: "hr-rest", withExtension: "json"),
            let stream = InputStream(url: url) {
            
            stream.open()
            
            do {
            
                let configuration = try OpenAPIReader.read(stream: stream)
                
                print(configuration.description)
            
            } catch {
                XCTFail("\(error)")
            }
            stream.close()
            
        } else {
            XCTFail("Failed to find test data file.")
        }
    }
    
}
