//
//  URI.swift
//  Pods
//
//  Created by Tony Stone on 8/28/16.
//
//

import Foundation

class URI {
    
    fileprivate let uri: URLComponents
    
    public init?(string URLString: String) {
        
        guard let uri = URLComponents(string: URLString) else {
            return nil
        }
        self.uri = uri
    }
}

extension URI : CustomStringConvertible, CustomDebugStringConvertible {
    
    var description: String {
        get {
            if let string = self.uri.string {
                return string
            }
            return self.uri.description
        }
    }
    
    var debugDescription: String {
        get {  return self.description }
    }
}
