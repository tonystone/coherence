//: Playground - noun: a place where people can play

import UIKit
import CoreData

import Coherence

let connect: Connect = GenericConnect<ContextStrategy.Mixed>(name: "PlayModel", managedObjectModel: PlayModel.newInstance())

try connect.start()
