//
//  WADLResource.swift
//  Pods
//
//  Created by Tony Stone on 8/26/16.
//
//

import Swift


/**
    WADL Resource Element
 
    - Seealso: 
 
        [Web Application Description Language, 2.6 Resource](https://www.w3.org/Submission/wadl/#x3-120002.6)
 
 
<xs:element name="resource">
    <xs:complexType>
      <xs:sequence>
        <xs:element ref="tns:doc" minOccurs="0" maxOccurs="unbounded"/>
        <xs:element ref="tns:param" minOccurs="0" maxOccurs="unbounded"/>
        <xs:choice minOccurs="0" maxOccurs="unbounded">
          <xs:element ref="tns:method"/>
          <xs:element ref="tns:resource"/>
        </xs:choice>
        <xs:any minOccurs="0" maxOccurs="unbounded" namespace="##other"
          processContents="lax"/>
      </xs:sequence>
      <xs:attribute name="id" type="xs:ID"/>
      <xs:attribute name="type" type="tns:resource_type_list"/>
      <xs:attribute name="queryType" type="xs:string"
        default="application/x-www-form-urlencoded"/>
      <xs:attribute name="path" type="xs:string"/>
      <xs:anyAttribute namespace="##other" processContents="lax"/>
    </xs:complexType>
  </xs:element>
 */

class WADLResource : WADLElement {
    
    init(id: String?, path: String?, type: String?, queryType: WADLQueryType = .applicationFormURLEncoded, parent: WADLElement?) {
        self.id = id
        self.path = path
        self.type = type
        self.queryType = queryType
        self.parent = parent
    }
    
    // Attributes
    let id: String?
    let path: String?
    let type: String?
    let queryType: WADLQueryType
    
    var otherAttributes: [String : String] = [:]
    
    // Elements
    var docs: [WADLDoc]             = []
    var params: [WADLParam]         = []
    var methods: [WADLMethod]       = []
    var resources: [WADLResource]   = []
    
    var otherElements: [XMLElement] = []
    
    weak var parent: WADLElement?
}
