//
//  GenericAction.swift
//  Pods
//
//  Created by Tony Stone on 1/22/17.
//
//

import Foundation

public protocol GenericAction: Action {

    func execute() -> (status: Int, headers: [String: String], objects: [Any], error: Error?)
}
