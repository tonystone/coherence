///
///  ActionContainer+Statistics.swift
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
/// Extension to implement the Statistics implementation of ActionContainer.
///
internal extension ActionContainer {

    ///
    /// ActionStatistics implementation for rhe container.
    ///
    internal class Statistics: ActionStatistics {

        public private(set) var startTime:  Date? = nil
        public private(set) var finishTime: Date? = nil

        public var executionTime: TimeInterval {
            guard let start = self.startTime, let finish = self.finishTime else {
                return 0
            }
            return finish.timeIntervalSince(start)
        }

        public internal(set) var contextStatistics: ContextStatistics? = nil

        @inline(__always)
        internal func start() { self.startTime = Date() }

        @inline(__always)
        internal func stop() { self.finishTime = Date() }
    }
}

extension ActionContainer.Statistics: CustomStringConvertible {

    public var description: String {
        var string = String(format: "{\r\texecutionTime: %.4f {", self.executionTime)

        if let contextStatistics = self.contextStatistics {
            let indentedStatistics = "\(contextStatistics)".indent(by: 2)
            string.append("\r\t\t   context: \(indentedStatistics)")
        }

        string.append("\r\t\t startTime: \(self.startTime?.description ?? "(not started)")")
        string.append("\r\t\tfinishTime: \(self.finishTime?.description ?? "(not started)")")

        string.append("\r\t\t}\r\t}")
        return string
    }
}

