///
///  Bundle+Extensions.swift
///
///  Copyright 2017 Tony Stone
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
///  Created by Tony Stone on 3/5/17.
///
import Swift

///
/// Internal extensions on Bundle.
///
internal extension Bundle {

    ///
    /// Returns the first URL for the managedObjectModel.
    ///
    /// Note: Will search for "momd" followed by "mom"
    ///
    internal class func url(forManagedObjectModelName name: String, preferredBundle bundle: Bundle = Bundle.main) -> URL? {

        var url: URL? = bundle.url(forResource: name, withExtension: "momd") ?? bundle.url(forResource: name, withExtension: "mom")

        if url == nil {

            /// Check the inner bundles if not found in the main bundle
            for innerBundle in Bundle.allBundles {
                url = innerBundle.url(forResource: name, withExtension: "momd") ?? innerBundle.url(forResource: name, withExtension: "mom")

                if url != nil {
                    break
                }
            }
        }
        return url
    }
}
