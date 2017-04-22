///
///  FileBackedSequence.swift
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
///  Created by Tony Stone on 4/21/17.
///
import Swift
import Darwin

///
/// A file backed - memory mapped implmentation of the `Sequence` protocol.
///
internal class FileBackedSequence: Sequence {

    enum Errors: Error {
        case couldNotOpenFile(String)
        case failedToMapFile(String)
    }

    ///
    /// Tracks the sequence number in this instance.
    ///
    /// - Note: Access must be synchronized with objc_sync_enter(self) and objc_sync_exit(self) pairs
    ///
    private var sequence: (next: UnsafeMutablePointer<Int>, map: UnsafeMutableRawPointer)

    ///
    /// The start of the sequence.
    ///
    public let start: Int

    public init(url: URL, start: Int = 1) throws {

        try FileBackedSequence.createFileIfMissing(url: url, start: start)

        self.sequence = try FileBackedSequence.mappedSequencePointer(url: url)

        self.start = self.sequence.next.pointee
    }

    deinit {
        munmap(sequence.map, Int(getpagesize()))
    }

    class func createFileIfMissing(url: URL, start: Int) throws {

        if !FileManager.default.fileExists(atPath: url.path) {
            var value = start
            try Data(buffer: UnsafeBufferPointer(start: &value, count: 1)).write(to: url, options: .atomic)
        }
    }

    class func mappedSequencePointer(url: URL) throws -> (UnsafeMutablePointer<Int>, UnsafeMutableRawPointer) {

        /// Open the file system file.
        let fd = open(url.path, O_RDWR)
        guard fd > 0
            else  { throw Errors.couldNotOpenFile("Could not open file \(url.path)") }

        /// Create a memory map for the file holding the sequence number
        let map = mmap(nil, Int(getpagesize()), PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0)!

        /// We no longer need the file descriptor since the memory map does not use it.
        close(fd)

        /// Create a cast pointer to the location
        let pointer = map.assumingMemoryBound(to: Int.self)

        if (Int(bitPattern: pointer) == -1) {    //MAP_FAILED not available, but its value is (void*)-1
            throw Errors.failedToMapFile("Failed to map file at \(url.path)")
        }
        return (pointer, map)
    }

    internal func nextBlock(size: Int) -> ClosedRange<Int> {

        ///
        /// We use objc locking here because was tested to be 7x faster than using a GCD queue for synchronization.
        ///
        objc_sync_enter(self)
        defer {
            objc_sync_exit(self)
        }

        let blockStart = sequence.next.pointee
        let blockEnd   = sequence.next.pointee + size - 1

        sequence.next.pointee = blockEnd + 1

        return blockStart...blockEnd
    }
}
