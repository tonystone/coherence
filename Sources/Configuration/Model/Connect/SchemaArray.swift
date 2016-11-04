//
//  SchemaArray.swift
//  Pods
//
//  Created by Tony Stone on 9/23/16.
//
//

import Swift

class SchemaArray : SchemaType {
    
    required init(element: SchemaType /*, minItems: Int?, maxItems: Int?, uniqueItems: Bool = false */) {
        self.element = element
//        self.uniqueItems = uniqueItems
    }
    
    let element: SchemaType
//    let minItems: Int
//    let maxItems: Int
//    let uniqueItems: Bool
}


///
/// Custom String Printing
///
extension SchemaArray : CustomStringConvertible, CustomDebugStringConvertible, IndentedStringConvertable  {
    
    var description: String {
        return description(indent: 0)
    }
    
    var debugDescription: String {
        return description(indent: 0)
    }
    
    func description(indent indent: Int, indentFirst: Bool = true) -> String {
        
        var description = "\(String(repeating: "\t", count: indentFirst ? indent : 0))["
        
        description.append("\r\(element.description(indent: indent + 1, indentFirst: true))")
        
        description.append("\r\(String(repeating: "\t", count: indent))]")
        
        return description
    }
}




