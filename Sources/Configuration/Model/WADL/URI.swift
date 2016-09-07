//
//  URI.swift
//  Pods
//
//  Created by Tony Stone on 8/28/16.
//
//

import Foundation

class URI {
    
    let urlComponents: URLComponents
    
    public init?(url: URL) {
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return nil
        }
        self.urlComponents = urlComponents
    }
    
    public init?(string URLString: String) {
        
        guard let uri = URLComponents(string: URLString) else {
            return nil
        }
        self.urlComponents = uri
    }
    
    var string: String? { get { return urlComponents.string } }
}

extension URI : CustomStringConvertible, CustomDebugStringConvertible {
    
    var description: String {
        get {
            if let string = self.urlComponents.string {
                return string
            }
            return self.urlComponents.description
        }
    }
    
    var debugDescription: String {
        get {  return self.description }
    }
}
