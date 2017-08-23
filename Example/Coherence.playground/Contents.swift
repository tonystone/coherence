//: Playground - noun: a place where people can play

import UIKit
import CoreData

@testable import Coherence

let ptr = UnsafeMutablePointer<String>.allocate(capacity: 1)

ptr.initialize(to: "This is a test String")

print(ptr.pointee)

ptr.deinitialize()
ptr.deallocate(capacity: 1)
