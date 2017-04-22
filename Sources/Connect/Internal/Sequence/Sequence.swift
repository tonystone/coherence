///
///  Sequence.swift
///  Pods
///
///  Created by Tony Stone on 4/22/17.
///
///
import Swift

internal protocol Sequence {

    ///
    /// Returns the starting position of this instance of Sequence.
    ///
    var start: Int { get }

    ///
    /// Returns a block a sequence numbers of size as a `ClosedRange`.
    ///
    func nextBlock(size: Int) -> ClosedRange<Int>
}
