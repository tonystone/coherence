///
///  EntitySettings.swift
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
///  Created by Tony Stone on 8/22/16.
///
import Foundation

//
// Default Entity settings for system
//
public let managedDefault: Bool                   = false
public let uniquenessAttributesDefault: [String]? = nil
public let stalenessIntervalDefault: Int          = 60
public let logTransactionsDefault: Bool           = true

//
// Method keys
//
internal var managedKey:              UInt8 = 0
internal var uniquenessAttributesKey: UInt8 = 0
internal var stalenessIntervalKey:    UInt8 = 0
internal var logTransactionsKey:      UInt8 = 0
