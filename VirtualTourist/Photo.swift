//
//  File.swift
//  VirtualTourist
//
//  Created by Mikael Mukhsikaroyan on 3/2/16.
//  Copyright © 2016 msquared. All rights reserved.
//

import UIKit
import CoreData

class Photo: NSManagedObject {
    
    @NSManaged var imageUrl: String
    @NSManaged var imageData: NSData?
    @NSManaged var pin: Pin
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    convenience init(imageUrl: String, imageData: NSData?, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        
        let path = pathForUrl(imageUrl)
        
        self.imageUrl = imageUrl
        if let data = imageData {
            self.imageData = data
            NSKeyedArchiver.archiveRootObject(data, toFile: path)
        }
    }
    
    func pathForUrl(url: String) -> String {
        let documentsDirectoryUrl = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        let fullUrl = documentsDirectoryUrl.URLByAppendingPathComponent(url)
        
        return fullUrl.path!
    }
    
}
