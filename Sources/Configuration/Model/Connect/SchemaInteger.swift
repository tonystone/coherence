//
//  SchemaInteger.swift
//  Pods
//
//  Created by Tony Stone on 9/24/16.
//
//

import Swift

class SchemaInteger : SchemaPrimitiveType {
    
    required init(required: Bool) {
        self.required = required
    }
    
    var type: String { return "integer" }
    let required: Bool
}
