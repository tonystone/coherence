//
//  ActionProxy.swift
//  Pods
//
//  Created by Tony Stone on 1/21/17.
//
//
import Foundation

public protocol ActionProxy {

    // MARK - Status

    var state: ActionState { get }

    var completionStatus: ActionCompletionStatus { get }

    var error: Error? { get }

    // MARK: - Statistics 

    var startTime: Date? { get }

    var finishTime: Date? { get }

    var executionTime: TimeInterval? { get }

    // MARK - Control

    func cancel()
}
