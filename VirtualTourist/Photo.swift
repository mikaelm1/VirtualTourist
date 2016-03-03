//
//  File.swift
//  VirtualTourist
//
//  Created by Mikael Mukhsikaroyan on 3/2/16.
//  Copyright © 2016 msquared. All rights reserved.
//

import Foundation
import CoreData

class Photo: NSManagedObject {
    
    @NSManaged var imageUrl: String
    @NSManaged var imageData: NSData
    @NSManaged var pin: Pin? 
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    convenience init(imageUrl: String, imageData:NSData, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.imageUrl = imageUrl
        self.imageData = imageData
    }
    
}
