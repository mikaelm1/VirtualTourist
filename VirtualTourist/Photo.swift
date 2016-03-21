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
    @NSManaged var filePath: String
    @NSManaged var pin: Pin
    
    var imageData: NSData?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    convenience init(imageUrl: String, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        self.imageUrl = imageUrl
        self.filePath = pathForUrl((NSURL(string: self.imageUrl)!.lastPathComponent)!)
    }
    
    func pathForUrl(url: String) -> String {
        let documentsDirectoryUrl = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        let fullUrl = documentsDirectoryUrl.URLByAppendingPathComponent(url)
        
        return fullUrl.path!
    }
    
    override func prepareForDeletion() {
        print("About to delete a Photo object")
        let path = pathForUrl((NSURL(string: self.imageUrl)?.lastPathComponent)!)
        do {
            try NSFileManager.defaultManager().removeItemAtPath(path)
            print("Deleted from Documents Directory")
        } catch {
            print("Photo was not deleted from File Manager: \(error)")
        }
    }
    
}
