///
///  Action.swift
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
///  Created by Tony Stone on 8/21/16.
///
import Foundation
import CoreData

public enum ActionState {
    case created
    case pending
    case executing
    case finished
}

public enum ActionCompletionStatus {
    case unknown
    case successful
    case canceled
    case failed
}

public protocol Action {

    ///
    /// All Actions must be cancelable
    ///
    func cancel()
}
