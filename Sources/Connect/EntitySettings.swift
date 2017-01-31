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

///
/// Settings available for each entity defined in your model.
///
/// - Note: You can override each of these per entity in the model or from the NSEntityDescription programatically.
///
public protocol EntitySettings {

    ///
    /// Is this entity managed by Connect?
    ///
    /// By default, objects are not managed until they pass
    /// the criteria that Connect sets for being able to
    /// manage a specific entity.
    ///
    var managed: Bool { get }

    ///
    /// Gets the attributes used to define a unique record for this entity type.  This can only be set
    /// statically in the  ManagedObjectModel for this entity.
    ///
    /// The default is nil for this value.
    ///
    var uniquenessAttributes: [String]? { get }

    ///
    /// Sets the amount of time before the resource is updated again from the master source
    ///
    var stalenessInterval: Int { get set }

    ///
    /// Should Connect log transactions for this entity?
    ///
    /// The default value is false for all entities.  You must set
    /// this value if you want Connect to log transactions for this
    /// entity.
    ///
    var logTransactions: Bool { get set }
}

//
// Default Entity settings for system
//
internal let managedDefault: Bool = false
internal let uniquenessAttributesDefault: [String]? = nil
internal let stalenessIntervalDefault: Int          = 600
internal let logTransactionsDefault: Bool           = false
