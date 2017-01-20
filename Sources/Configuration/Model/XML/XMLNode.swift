//
//  XMLNode.swift
//  Pods
//
//  Created by Tony Stone on 8/26/16.
//
//

import Foundation


//enum XMLNodeType : Int {
//    case Element = 1
//    case Attr = 2
//    case Text = 3
//    case CDATASection = 4
//    case EntityReference = 5
//    case Entity = 6
//    case ProcessingInstruction = 7
//    case Comment = 8
//    case Docuement  = 9
//    case DocumentType = 10
//    case DocumentFragment = 11
//    case Notation = 12
//}

class XMLNode {

    var nodeName: String {
        get { return String(reflecting: self) }
        
    }
//    var value: String { get }
//    
    var attributes: [String : String] = [:]
    var children: [XMLNode] = []

    func add(_ child: XMLNode) {
        self.children.append(child)
    }
}


//class XMLNode {
//    
//    enum NodeType : Int {
//        case Element = 1
//        case Attr = 2
//        case Text = 3
//        case CDATASection = 4
//        case EntityReference = 5
//        case Entity = 6
//        case ProcessingInstruction = 7
//        case Comment = 8
//        case Docuement  = 9
//        case DocumentType = 10
//        case DocumentFragment = 11
//        case Notation = 12
//    }
//    
//    init(nodeType: NodeType)
//    
//    let nodeType: NodeType
//    var type: NodeType
//    var name: String { get
//        return "\(nodeType)"
//    }
//    var value: String { get }
//    
//    var attributes: [String : String] { get set }
//    var children: [XMLNode] { get set }
//    
//    mutating func add(_ child: XMLNode)
//}
