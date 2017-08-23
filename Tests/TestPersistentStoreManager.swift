///
///  TestPersistentStoreManager.swift
///
///  Copyright 2016 Tony Stone
///
///  Licensed under the Apache License, Version 2.0 (the "License");
///  you may not use this file except in compliance with the License.
///  You may obtain a copy of the License at
///
///  http://www.apache.org/licenses/LICENSE-2.0
///
///  Unless required by applicable law or agreed to in writing, software
///  distributed under the License is distributed on an "AS IS" BASIS,
///  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
///  See the License for the specific language governing permissions and
///  limitations under the License.
///
///  Created by Tony Stone on 10/31/16.
///
import Foundation
import CoreData
///
/// We require the StoreConfiguration as rtestable so we can use
/// the storeURL func.
///
@testable import Coherence

internal class TestPersistentStoreManager {

     class func defaultPersistentStoreDirectory() -> URL {

        return GenericPersistentContainer<ContextStrategy.Mixed>.defaultStoreLocation()
    }

    private class func storeURL(storePrefix: String, storeType: String,  configuration: String? = nil) -> URL {

        /// Note: StoreConfiguration.storeURL is tested for returning the correct location given
        /// its inputs so as long as those tests pass, we can trust that this method is giving the 
        /// correct results for the remainder of the tests that use this.
        return StoreConfiguration.storeURL(prefix: storePrefix, configuration: configuration, type: storeType, location: defaultPersistentStoreDirectory())
    }

    class func removePersistentStoreCache(at url: URL) throws {

        let fileManager = FileManager.default

        if fileManager.fileExists(atPath: url.path) {
            let files = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: [.nameKey], options: .skipsHiddenFiles)

            for file in files {
                try fileManager.removeItem(at: file)
            }
        }
    }

    class func removePersistentStoreCache() throws {

        try removePersistentStoreCache(at: defaultPersistentStoreDirectory())
    }
    
    class func persistentStoreDate(url: URL?) throws -> Date {

        guard let url = url
                else { throw NSError(domain: "TestErrorDomain", code: 100, userInfo: [NSLocalizedDescriptionKey: "Nil url passed."]) }


        let attributes = try FileManager.default.attributesOfItem(atPath: url.path)

        guard let date = attributes[FileAttributeKey.creationDate] as? Date else {
            throw NSError(domain: "TestErrorDomain", code: 100, userInfo: [NSLocalizedDescriptionKey: "No creation date returned"])
        }
        return date
    }
    
    class func persistentStoreDate(storePrefix: String, storeType: String, configuration: String? = nil) throws -> Date {

        let storePath = self.storeURL(storePrefix: storePrefix, storeType: storeType, configuration: configuration).path

        let attributes = try FileManager.default.attributesOfItem(atPath: storePath)

        guard let date = attributes[FileAttributeKey.creationDate] as? Date else {
            throw NSError(domain: "TestErrorDomain", code: 100, userInfo: [NSLocalizedDescriptionKey: "No creation date returned"])
        }
        return date
    }
    
    class func persistentStoreExists(url: URL?) -> Bool {

        guard let url = url
                else { return false }

        return FileManager.default.fileExists(atPath: url.path)
    }
    
    class func persistentStoreExists(storePrefix: String, storeType: String,  configuration: String? = nil) -> Bool {

        let storePath = self.storeURL(storePrefix: storePrefix, storeType: storeType, configuration: configuration).path

        return FileManager.default.fileExists(atPath: storePath)
    }
    
    class func deleteIfExists(fileURL url: URL) throws {

        let fileManager = FileManager.default
        let path = url.path

        if fileManager.fileExists(atPath: path) {
            try fileManager.removeItem(at: url)
        }
    }


}
