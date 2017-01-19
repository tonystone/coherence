//
//  EntitySettings.swift
//  Pods
//
//  Created by Tony Stone on 8/22/16.
//
//

import Foundation

//
// Default Entity settings for system
//
public let managedDefault           = false
public let stalenessIntervalDefault = 60
public let logTransactionsDefault   = true

//
// Method keys
//
internal var managedKey: UInt8 = 0
internal var stalenessIntervalKey: UInt8 = 0
internal var logTransactionsKey: UInt8 = 0
