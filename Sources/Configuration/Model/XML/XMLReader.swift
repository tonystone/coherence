//
//  XMLReader.swift
//  Pods
//
//  Created by Tony Stone on 8/26/16.
//
//

import Foundation

class XMLReader {
    
    class func document(contentsOfURL url: URL) throws -> XMLDocument {
        let delegate = XMLParserDelegate()
        
        if let parser = XMLParser(contentsOf: url) {
            
            parser.delegate = delegate
            parser.shouldProcessNamespaces = true
            parser.shouldReportNamespacePrefixes = true
            parser.shouldResolveExternalEntities = true
        
            parser.parse()
        }
        return delegate.document
    }
}
