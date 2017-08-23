///
///  Connect.swift
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
///  Created by Tony Stone on 4/1/17.
///
import Swift
import CoreData

internal struct Log {
    ///
    /// Tag used for all logging internally
    ///
    internal static let tag = "Connect"
}

///
/// Connect
///
/// A container that encapsulates the Core Data stack in your application and
/// Manages all resources from threads to web services.
///
/// Connect offers managed execution of actions (either generic or entity specific)
/// which can be monitored and managed via proxy execution objects.  Execution of
/// generic action happen on a concurrent queue while entity actions are executed
/// in a specific serial queue for each type.  This forces synchronization of
/// operations by type.
///
public protocol Connect: PersistentStack {

    ///
    /// Synchronously start the instance of `Connect`
    ///
    /// - Throws: If an error occurs.
    ///
    func start() throws

    ///
    /// Asynchronously start the instance of `Connect`
    ///
    /// - Parameter block: Block to call when the startup sequence is complete. If an error occurs, `Error` will be non nil and contain the error indicating the reason for the failure.
    ///
    func start(block: @escaping (Error?) -> Void)

    ///
    /// Synchronously stop the instance of `Connect` unloading the persistent stores.
    ///
    /// - Throws: If an error occurs.
    ///
    func stop() throws

    ///
    /// Asynchronously stop the instance of `Connect` unloading the persistent stores.
    ///
    /// - Parameter block: Block to call when the shutdown sequence is complete. If an error occurs, `Error` will be non nil and contain the error indicating the reason for the failure.
    ///
    func stop(block: @escaping (Error?) -> Void)

    ///
    /// Suspend or resume the operation of `Connect`.
    ///
    /// - Note: This will suspend or activate all Queues.
    ///
    var suspended: Bool { get set }

    ///
    /// Execute a generic action in a concurrent queue.
    ///
    /// - Parameters:
    ///     - action: The `GenericAction` implementation to execute.
    ///
    /// - Returns: An `ActionProxy` that represents your action.  This can be used to manage and monitor the action's status.
    ///
    /// - SeeAlso: `GenericAction` protocol
    /// - SeeAlso: `ActionProxy` protocol
    ///
    @discardableResult
    func execute<ActionType: GenericAction>(_ action: ActionType) throws -> ActionProxy

    ///
    /// Execute a generic action in a concurrent queue.
    ///
    /// - Parameters:
    ///     - action: The `GenericAction` implementation to execute.
    ///     - completionBlock: An optional block that will be called after teh action completes (succeeds or fails).
    ///
    /// - Returns: An `ActionProxy` that represents your action.  This can be used to manage and monitor the action's status.
    ///
    /// - SeeAlso: `GenericAction` protocol
    /// - SeeAlso: `ActionProxy` protocol
    ///
    @discardableResult
    func execute<ActionType: GenericAction>(_ action: ActionType, completionBlock: ((_ actionProxy: ActionProxy) -> Void)?) throws -> ActionProxy

    ///
    /// Execute a entity action in a serial queue. Entity actions also get passed a specific action context for access to the persistent storage.
    ///
    /// - Parameters:
    ///     - action: The `EntityAction` implementation to execute.
    ///
    /// - Returns: An `ActionProxy` that represents your action.  This can be used to manage and monitor the action's status.
    ///
    /// - SeeAlso: `EntityAction` protocol
    /// - SeeAlso: `ActionProxy` protocol
    ///
    @discardableResult
    func execute<ActionType: EntityAction>(_ action: ActionType) throws -> ActionProxy

    ///
    /// Execute a entity action in a serial queue. Entity actions also get passed a specific action context for access to the persistent storage.
    ///
    /// - Parameters:
    ///     - action: The `EntityAction` implementation to execute.
    ///     - completionBlock: An optional block that will be called after teh action completes (succeeds or fails).
    ///
    /// - Returns: An `ActionProxy` that represents your action.  This can be used to manage and monitor the action's status.
    ///
    /// - SeeAlso: `EntityAction` protocol
    /// - SeeAlso: `ActionProxy` protocol
    ///
    @discardableResult
    func execute<ActionType: EntityAction>(_ action: ActionType, completionBlock: ((_ actionProxy: ActionProxy) -> Void)?) throws -> ActionProxy
}
