//
//  SchemaNumber.swift
//  Pods
//
//  Created by Tony Stone on 9/23/16.
//
//

import Swift

class SchemaNumber : SchemaPrimitiveType {

    required init(required: Bool) {
        self.required = required
    }
    
    var type: String { return "number" }
    let required: Bool
}
