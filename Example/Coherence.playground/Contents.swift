//: Playground - noun: a place where people can play

import UIKit
@testable import Coherence

let metaModel = MetaModel()

let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,.UserDomainMask, true)[0] as String

let logWriter = try  WriteAheadLog(url: NSURL(fileURLWithPath: documentsPath))

//var logEntry: MetaLogEntry = NSEntityDescription.entityForName(", inManagedObjectContext: <#T##NSManagedObjectContext#>)
var currentTimestamp = NSDate().timeIntervalSinceNow
//logEntry.timestamp = NSDate().timeIntervalSinceNow





