//
//  ConfigurationReader.swift
//  Pods
//
//  Created by Tony Stone on 9/12/16.
//
//

import Swift

protocol ConfigurationReader {
    
    static func read(stream stream: InputStream, sourceURL: URL?) throws -> Configuration
}
