//
//  ParameterDescription.swift
//  Pods
//
//  Created by Tony Stone on 9/19/16.
//
//

import Swift

class PrimitiveParameterDescription : ParameterType {

    init(name: String, location: ParameterLocation, type: SchemaPrimitiveType, required: Bool) {
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

