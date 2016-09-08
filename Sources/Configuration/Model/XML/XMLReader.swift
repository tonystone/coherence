//
//  XMLReader.swift
//  Pods
//
//  Created by Tony Stone on 8/26/16.
//
//

import Foundation

class XMLReader {
    
    class func document(stream stream: InputStream) throws -> XMLDocument {
        let delegate = XMLParserDelegate()
        
        let parser = XMLParser(stream: stream)
            
        parser.delegate = delegate
        parser.shouldProcessNamespaces = true
        parser.shouldReportNamespacePrefixes = true
        parser.shouldResolveExternalEntities = true
        
        parser.parse()

        return delegate.document
    }
}
