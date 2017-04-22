///
///  InMemorySequence.swift
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
///  Created by Tony Stone on 4/22/17.
///
import Swift

///
/// An pure in-memory implmentation of the `Sequence` protocol.
///
internal class InMemorySequence: Sequence {

    ///
    /// Tracks the sequence number in this instance.
    ///
    /// - Note: Access must be synchronized with objc_sync_enter(self) and objc_sync_exit(self) pairs
    ///
    private var next: Int

    ///
    /// The start of the sequence.
    ///
    public let start: Int

    public init(start: Int = 1) {

        self.start = start
        self.next  = start
    }

    internal func nextBlock(size: Int) -> ClosedRange<Int> {

        ///
        /// We use objc locking here because was tested to be 7x faster than using a GCD queue for synchronization.
        ///
        objc_sync_enter(self)
        defer {
            objc_sync_exit(self)
        }

        let blockStart = self.next
        let blockEnd   = self.next + size - 1
        
        self.next = blockEnd + 1
        
        return blockStart...blockEnd
    }
}

