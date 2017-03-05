///
///  MockBaseAction.swift
///  Coherence
///
///  Created by Tony Stone on 3/4/17.
///  Copyright © 2017 Tony Stone. All rights reserved.
///
import TraceLog
import Coherence

class MockBaseAction {

    internal enum Errors: Error {
        case forcedError
    }

    private let waitUntilCanceled: Bool

    private var waitSemaphore: DispatchSemaphore
    private let waitTimeout: Double
    private let forceError: Bool

    init(waitUntilCanceled: Bool = false, timeout: Double = 5, forceError: Bool = false) {
        self.waitUntilCanceled = waitUntilCanceled
        self.waitSemaphore     = DispatchSemaphore(value: 0)
        self.waitTimeout       = timeout
        self.forceError        = forceError
    }

    internal func start() throws -> Bool {

        var result = true

        if self.waitUntilCanceled {
            if self.waitSemaphore.wait(timeout: .now() + self.waitTimeout) == .success {
                logInfo { "Canceled." }

                result = false
            }
        }
        guard !forceError else {
            throw Errors.forcedError
        }
        return result
    }

    ///
    /// All Actions must be cancelable
    ///
    public func cancel() {
        self.waitSemaphore.signal()
    }
}

