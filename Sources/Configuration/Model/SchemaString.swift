//
//  SchemaString.swift
//  Pods
//
//  Created by Tony Stone on 9/23/16.
//
//

import Swift

class SchemaString : SchemaPrimitiveType {

    required init(required: Bool) {
        self.required = required
    }
    
    var type: String { return "string" }
    let required: Bool
}
