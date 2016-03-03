//
//  MapLocation.swift
//  VirtualTourist
//
//  Created by Mikael Mukhsikaroyan on 3/2/16.
//  Copyright © 2016 msquared. All rights reserved.
//

import Foundation
import CoreData

class MapLocation: NSManagedObject {
    
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    convenience init(latitude: Double, longitude: Double, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("MapLocation", inManagedObjectContext: context)!
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        
    }
}
