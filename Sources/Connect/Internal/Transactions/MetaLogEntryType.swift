///
///  MetaLogEntryType.swift
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
///  Created by Tony Stone on 3/6/17.
///
import Swift

///
/// The type of the MetaLogEntry class which are used to track transactions.
///
@objc
internal enum MetaLogEntryType: Int32, CustomStringConvertible {
    case beginMarker = 0xf0
    case endMarker   = 0xf1
    case insert      = 0x64
    case update      = 0x65
    case delete      = 0x66

    public var description: String {
        switch self {
        case .beginMarker: return "Xtran Begin Marker"
        case .endMarker:   return "Xtran End marker"
        case .insert:      return "Insert"
        case .update:      return "Update"
        case .delete:      return "Delete"
        }
    }
}
