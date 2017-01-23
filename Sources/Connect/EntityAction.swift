//
//  EntityAction.swift
//  Pods
//
//  Created by Tony Stone on 1/22/17.
//
//

import Foundation
import CoreData

public protocol EntityAction: Action {

    associatedtype EntityType: NSManagedObject

    func execute(context: NSManagedObjectContext) -> (status: Int, headers: [String: String], objects: [Any], error: Error?)
}
