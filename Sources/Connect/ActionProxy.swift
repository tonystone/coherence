///
///  ActionProxy.swift
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
///  Created by Tony Stone on 1/21/17.
///
import Foundation

///
/// A type representing the current execution state
/// of an `Action`.
///
public enum ActionState {
    case created    /// The `Action` was created but has not executed.
    case pending    /// The `Action` is pending execution in a queue.
    case executing  /// The `Action` is currently executing.
    case finished   /// The `Action` has completed executing.
}

///
/// The completion status of an `Action`.
///
public enum ActionCompletionStatus {
    case unknown        /// If the `Action` has not executed, its `ActionCompletionStatus` will be `.unknown`.
    case successful     /// The `Action` completed successfully.
    case canceled       /// The `Action` was canceled either before or during exection.
    case failed         /// The `Action` failed to execute completely.
}

///
/// Statistics of an `Action` during and 
/// after its been executed.
///
public protocol ActionStatistics {

    ///
    /// If the `Action` has started, startTime will be set
    /// with the start time.
    ///
    var startTime: Date? { get }

    ///
    /// If the `Action` has finished, finshTime will be set
    /// with the finish time.
    ///
    var finishTime: Date? { get }

    ///
    /// If the `Action` has run, executionTime will be set
    /// with the total execution time (minus your completion block time).
    ///
    var executionTime: TimeInterval { get }
}

///
/// The executing an `Action`, an instance of `ActionProxy` will
/// be returned which allows control and monitoring of the executing
/// `Action`.
///
public protocol ActionProxy {

    ///
    /// The action passed to this proxy
    ///
    /// - SeeAlso: `Action`
    ///
    var action: Action { get }

    // MARK - Status

    ///
    /// The current execution state of the action.
    ///
    /// - SeeAlso: `ActionState`
    ///
    var state: ActionState { get }

    ///
    /// If the `Action` has run, the completion status
    /// represents the results.  If it has not run, this
    /// value will be `.unknown`.
    ///
    /// - SeeAlso: `ActionCompletionStatus`
    ///
    var completionStatus: ActionCompletionStatus { get }

    ///
    /// If the `Action` has run and the completion status
    /// is `.failed`, error will contain and Error object
    /// detailing the failure.
    ///
    /// - SeeAlso: `Error`
    ///
    var error: Error? { get }

    // MARK: - Statistics

    ///
    /// The current statistics objects associated with this proxy.
    ///
    /// - SeeAlso: `ActionStatistics`
    ///
    var statistics: ActionStatistics { get }

    // MARK - Control

    ///
    /// If the `Action` has not run or is in the middle of running,
    /// cancel will cancel the remainder of the action.
    ///
    func cancel()
}
