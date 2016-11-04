//
//  ComplexParameterDescription.swift
//  Pods
//
//  Created by Tony Stone on 10/22/16.
//
//

class ComplexParameterDescription : ParameterType {
    
    init(name: String, location: ParameterLocation, type: SchemaType, required: Bool) {
        self.name = name
        self.location = location
        self.type = type
        self.required = required
    }
    
    var id: String {
        return "\(self.name).\(self.location)"
    }
    
    let name: String
    let location: ParameterLocation
    let type: SchemaType
    let required: Bool
}
