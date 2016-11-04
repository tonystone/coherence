//
//  SchemaNull.swift
//  Pods
//
//  Created by Tony Stone on 9/24/16.
//
//

import Swift

class SchemaNull : SchemaPrimitiveType {
    
    required init(required: Bool) {
        self.required = required
    }
    
    var type: String { return "null" }
    let required: Bool
}
