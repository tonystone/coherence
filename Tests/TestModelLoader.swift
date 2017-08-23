///
///  TestModelLoader.swift
///
///  Copyright © 2017 Tony Stone. All rights reserved.
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
///  Created by Tony Stone on 8/17/17.
///
import Swift
import CoreData

internal class TestModelLoader {

    class func load(name: String) -> NSManagedObjectModel {

        let bundle = Bundle(for: TestModelLoader.self)

        guard let url = bundle.url(forResource: name, withExtension: "momd") else {
            fatalError("Could not locate \(name).momd in bundle.")
        }
        guard let model = NSManagedObjectModel(contentsOf: url) else {
            fatalError("Failed to load model at \(url).")
        }
        return model
    }
}
