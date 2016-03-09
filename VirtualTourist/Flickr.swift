//
//  Flickr.swift
//  VirtualTourist
//
//  Created by Mikael Mukhsikaroyan on 2/29/16.
//  Copyright © 2016 msquared. All rights reserved.
//

import UIKit
import CoreData

typealias CompletionHandler = (result: [String: NSData]?, error: String?) -> Void

class Flickr {
    
    let session = NSURLSession.sharedSession()
    
    lazy var sharedContext: NSManagedObjectContext = {
        CoreDataStackManager.sharedInstance().managedObjectContext!
    }()
    
    //  https:api.flickr.com/services/rest/?method=flickr.photos.search&api_key=88569b3c55687dd564daf5dca5234002&lat=34&lon=-118&format=json&nojsoncallback=1&auth_token=72157662933309284-7a0c20512f3f9569&api_sig=8cbb9c5524e1e03fc71dbbbf492ac218
    
    func taskForLocation(latitude: Double, longitude: Double, completionHandler: CompletionHandler) -> NSURLSessionDataTask {
        
        var urlString = Constants.URLForPhotoSearch
        urlString = urlString.stringByReplacingOccurrencesOfString("latitude", withString: "\(latitude)")
        urlString = urlString.stringByReplacingOccurrencesOfString("longitude", withString: "\(longitude)")
        print("URLString: \(urlString)")
        
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            
            func sendError(error: String) {
                print(error)
                completionHandler(result: nil, error: "No result. Sending error")
            }
            
            guard (error == nil) else {
                sendError("There was an error with the request")
                return
            }
            
            guard let data = data else {
                sendError("No data was returned")
                return
            }
            //print("Data was returned")
            
            Flickr.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
            
        }
        task.resume()
        return task
    }
    
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: CompletionHandler) {
        print("parseJSONWithCompletionHandler")
        func sendError(error: String) {
            print(error)
            completionHandler(result: nil, error: "No result. Sending error")
        }
        
        let parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch let error as NSError {
            sendError("\(error)")
            return
        }
        //print("Parsed Results: \(parsedResult)")
        
        guard let photos = parsedResult["photos"] as? [String: AnyObject] else {
            sendError("Unable to get photos from JSON")
            return
        }
        //print(photos.count)
        //print("Photos \(photos)")
        
        guard let photosArrayOfDicts = photos["photo"] as? [[String: AnyObject]] else {
            sendError("Unable to get photos key")
            return
        }
        //print(photosArrayOfDicts[0])
        print("Count of photos returned: \(photosArrayOfDicts.count)")
        
        if photosArrayOfDicts.count == 0 {
            sendError("No photos Found. Search Again.")
            return
        } else {
            
            var imageDictionary = [String: NSData]()
            for photoDictionary in photosArrayOfDicts{
                let photo = photoDictionary as [String: AnyObject]
                
                guard let imageUrlString = photo["url_m"] as? String else {
                    sendError("Could not find key: url_m")
                    return
                }
                //print(imageUrlString)
                
                let imageURL = NSURL(string: imageUrlString)
                guard let imageData = NSData(contentsOfURL: imageURL!) else {
                    sendError("Unable to get image data")
                    return
                    //let _ = Photo(imageUrl: imageUrlString, imageData: imageData, context: self.sharedContext)
                }
                imageDictionary[imageUrlString] = imageData
            }
            completionHandler(result: imageDictionary, error: nil)
        }
    }
    
    
    
    // MARK: Shared Instance
    class func sharedInstance() -> Flickr {
        struct Singleton {
            static var sharedInstance = Flickr()
        }
        return Singleton.sharedInstance
    }
}
