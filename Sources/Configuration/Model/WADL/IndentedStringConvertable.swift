//
//  IndentedStringConvertable.swift
//  Pods
//
//  Created by Tony Stone on 9/6/16.
//
//

import Swift

internal protocol IndentedStringConvertable {
    func description(indent indent: Int, indentFirst: Bool) -> String
}
