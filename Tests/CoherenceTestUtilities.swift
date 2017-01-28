//
//  CoherenceTestUtilities.swift
//  Coherence
//
//  Created by Tony Stone on 10/31/16.
//  Copyright © 2016 Tony Stone. All rights reserved.
//

import Foundation

internal func cachesDirectory() throws -> URL {
    
    let fileManager = FileManager.default
    
    return try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
}


internal func removePersistentStoreCache() throws {
    
    let fileManager = FileManager.default
    
    let files = try fileManager.contentsOfDirectory(at: cachesDirectory(), includingPropertiesForKeys: [.nameKey], options: .skipsHiddenFiles)
    
    for file in files {
        try fileManager.removeItem(at: file)
    }
}

internal func persistentStoreDate(storePrefix: String, storeType: String, configuration: String? = nil) throws -> Date {
    
    let storePath = try cachesDirectory().appendingPathComponent("\(storePrefix)\(configuration?.lowercased() ?? "").\(storeType.lowercased())").path
    
    let attributes = try FileManager.default.attributesOfItem(atPath: storePath)
    
    guard let date = attributes[FileAttributeKey.creationDate] as? Date else {
        throw NSError(domain: "TestErrorDomain", code: 100, userInfo: [NSLocalizedDescriptionKey: "No creation date returned"])
    }
    return date
}

internal func persistentStoreExists(storePrefix: String, storeType: String,  configuration: String? = nil) throws -> Bool {
    
    let storePath = try cachesDirectory().appendingPathComponent("\(storePrefix)\(configuration?.lowercased() ?? "").\(storeType.lowercased())").path
    
    return FileManager.default.fileExists(atPath: storePath)
}

internal func deletePersistentStoreFilesIfExist(storePrefix: String, storeType: String, configuration: String? = nil) throws {
    
    let storeDirectory = try cachesDirectory()
    
    let storePath = storeDirectory.appendingPathComponent("\(storePrefix)\(configuration?.lowercased() ?? "").\(storeType.lowercased())").path
    
    let storeShmPath = "\(storePath)-shm"
    let storeWalPath = "\(storePath)-wal"
    
    try deleteIfExists(fileURL: URL(fileURLWithPath: storePath))
    try deleteIfExists(fileURL: URL(fileURLWithPath: storeShmPath))
    try deleteIfExists(fileURL: URL(fileURLWithPath: storeWalPath))
}

internal func deleteIfExists(fileURL url: URL) throws {
    
    let fileManager = FileManager.default
    let path = url.path
    
    if fileManager.fileExists(atPath: path) {
        try fileManager.removeItem(at: url)
    }
}
