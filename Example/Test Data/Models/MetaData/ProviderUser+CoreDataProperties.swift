//
//  ProviderUser+CoreDataProperties.swift
//  
//
//  Created by Tony Stone on 8/21/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension ProviderUser {

    @NSManaged var email: String?
    @NSManaged var deviceReference: String?
    @NSManaged var selectedAccountReference: String?
    @NSManaged var providerData: NSObject?
    @NSManaged var providerReference: String?
    @NSManaged var eventFeedPath: String?
    @NSManaged var encryptedPassword: NSData?
    @NSManaged var providerName: String?

}
