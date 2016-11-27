//
//  Item+CoreDataProperties.swift
//  ShopList
//
//  Created by Josh Hunziker on 11/17/16.
//  Copyright © 2016 Josh Hunziker. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Item {

    @NSManaged var name: String?
    @NSManaged var pic: NSData?
    @NSManaged var quantity: String?

}
