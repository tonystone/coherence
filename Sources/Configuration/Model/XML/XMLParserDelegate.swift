//
//  XMLParserDelegate.swift
//  Pods
//
//  Created by Tony Stone on 8/26/16.
//
//

import Foundation
import TraceLog

class XMLParserDelegate : NSObject, Foundation.XMLParserDelegate {
    
    var document = XMLDocument()
    
    fileprivate var currentStringValue = String()
    fileprivate var nodeQueue = [XMLNode]()
    fileprivate let namespaceManager = NamespaceManager()
    fileprivate var elementNamespaces = [String : String]()
    
    func parserDidStartDocument(_ parser: XMLParser) {
        nodeQueue.append(document)
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        return
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        let element = XMLElement(name: elementName, qualifiedName: qName, namespaceURI: namespaceURI)
        
        element.namespaces = elementNamespaces
        elementNamespaces.removeAll() // Clear it for the next element
        
        element.attributes = attributeDict
        
        nodeQueue.append(element)
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        if nodeQueue.count > 0 {
            let currentElement = nodeQueue.removeLast()
            
            // If there is text in the element, add it as a text node
            if currentStringValue.characters.count > 0 {
                currentElement.add(XMLText(data: currentStringValue.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)))
            }
            // Link to the parent
            if var parentNode = nodeQueue.last {
                parentNode.add(currentElement)
            }
        }
        // Clear the current string for text
        currentStringValue.removeAll()
    }
    
    func parser(_ parser: XMLParser, didStartMappingPrefix prefix: String, toURI namespaceURI: String) {
        namespaceManager.beginScope(forPrefix: prefix, namespaceURI: namespaceURI)

        elementNamespaces[prefix] = namespaceURI
    }
    
    func parser(_ parser: XMLParser, didEndMappingPrefix prefix: String) {
        namespaceManager.endScope(forPrefix: prefix)
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentStringValue.append(string)
    }
    
    // The parser reports ignorable whitespace in the same way as characters it's found.
    public func parser(_ parser: XMLParser, foundIgnorableWhitespace whitespaceString: String) {
        if var node = nodeQueue.last {
            node.add(XMLText(data: whitespaceString))
        }
    }

    // A comment (Text in a <!-- --> block) is reported to the delegate as a single string
    func parser(_ parser: XMLParser, foundComment comment: String) {
        if var node = nodeQueue.last {
            node.add(XMLComment(data: comment))
        }
    }
    
    // this reports a CDATA block to the delegate as an NSData.
    func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
        if var node = nodeQueue.last {
            node.add(XMLCDATA(data: String(describing: CDATABlock)))
        }
    }
    
    // ...and this reports a fatal error to the delegate. The parser will stop parsing.
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        logError { "Parse error: \(parseError.localizedDescription)" }
    }

    func parser(_ parser: XMLParser, validationErrorOccurred validationError: Error) {
        logError { "Validation error: \(validationError.localizedDescription)" }
    }
}

private class NamespaceManager {
    
    fileprivate var inScopeNamespaces = [String : [String]]()
    
    func beginScope(forPrefix prefix: String, namespaceURI: String) {
        
        // Add the prefix to the inScope dictionary
        // and push the uri it's currently defined as onto the stack.
        if var namespaceStack = inScopeNamespaces[prefix] {
            namespaceStack.append(namespaceURI)
            
            inScopeNamespaces[prefix] = namespaceStack
        } else {
            inScopeNamespaces[prefix] = [namespaceURI]
        }
    }

    func endScope(forPrefix prefix: String) {
        
        if var namespaceStack = inScopeNamespaces[prefix] {
            namespaceStack.removeLast()
            
            if namespaceStack.count == 0 {
                inScopeNamespaces.removeValue(forKey: prefix)
            }
        }
    }

    func isInScope(_ prefix: String) -> Bool {
        return inScopeNamespaces[prefix] != nil
    }
}
