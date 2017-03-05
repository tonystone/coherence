///
///  String+Extensions.swift
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
import Foundation

///
/// Misc. internal String helper extensions
///
internal extension String {

    func indent(by count: Int, with char: String = "\t") -> String {
        ///
        /// Note: A regex like the following ended up being very slow so
        ///       we are using 2 straight replaces instead which is
        ////      much faster.
        ///
        /// return self.replacingOccurrences(of: "(\r\n|\r|\n)", with: "\r" + String(repeating: char, count: count), options: .regularExpression)
        ///
        let replacement = "\r" + String(repeating: char, count: count)
        return self.replacingOccurrences(of: "\n", with: replacement).replacingOccurrences(of: "\r", with: replacement)
    }
}
