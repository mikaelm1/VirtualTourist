//
//  Flickr.swift
//  VirtualTourist
//
//  Created by Mikael Mukhsikaroyan on 2/29/16.
//  Copyright © 2016 msquared. All rights reserved.
//

import UIKit
import CoreData

typealias CompletionHandler = (result: AnyObject!, error: String?) -> Void

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
        
        completionHandler(result: parsedResult, error: nil)
    }
    
    func taskForImageWithUrl(url: String, completionHandler: (imageData: NSData?, error: NSError?) -> Void) -> NSURLSessionTask {
        
        let url = NSURL(string: url)!
        
        let request = NSURLRequest(URL: url)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
            
            guard let imageData = data else {
                completionHandler(imageData: nil, error: error)
                return
            }
            completionHandler(imageData: imageData, error: nil)
        }
        return task 
    }
    
    
    
    // MARK: Shared Instance
    class func sharedInstance() -> Flickr {
        struct Singleton {
            static var sharedInstance = Flickr()
        }
        return Singleton.sharedInstance
    }
}
