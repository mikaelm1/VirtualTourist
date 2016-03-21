//
//  Flickr.swift
//  VirtualTourist
//
//  Created by Mikael Mukhsikaroyan on 2/29/16.
//  Copyright © 2016 msquared. All rights reserved.
//

import UIKit
import CoreData

typealias CompletionHandler = (result: [Photo]?, error: String?) -> Void

class Flickr {
    
    let session = NSURLSession.sharedSession()
    let sharedContext = CoreDataStackManager.sharedInstance().managedObjectContext!
    
    //  https:api.flickr.com/services/rest/?method=flickr.photos.search&api_key=88569b3c55687dd564daf5dca5234002&lat=34&lon=-118&format=json&nojsoncallback=1&auth_token=72157662933309284-7a0c20512f3f9569&api_sig=8cbb9c5524e1e03fc71dbbbf492ac218
    
    func taskForLocation(pin: Pin, completionHandler: CompletionHandler) -> NSURLSessionDataTask {
        
        let latitude = pin.latitude
        let longitude = pin.longitude
        let pageNumber = arc4random_uniform(100)
        print("Random page number: \(pageNumber)")
        var urlString = Constants.URLForPhotoSearch
        urlString = urlString.stringByReplacingOccurrencesOfString("latitude", withString: "\(latitude)")
        urlString = urlString.stringByReplacingOccurrencesOfString("longitude", withString: "\(longitude)")
        urlString = urlString.stringByReplacingOccurrencesOfString("pageNumber", withString: "\(pageNumber)")
        //print("URLString: \(urlString)")
        
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
            
            Flickr.parseJSONWithCompletionHandler(data, pin: pin, completionHandler: completionHandler)
            
        }
        task.resume()
        return task
    }
    
    class func parseJSONWithCompletionHandler(data: NSData, pin: Pin, completionHandler: CompletionHandler) {
        //print("parseJSONWithCompletionHandler")
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
        var photosToReturn = [Photo]()

        if let parsedResult = parsedResult {
            print("Got parsed results")
            guard let photos = parsedResult["photos"] as? [String: AnyObject] else {
                return
            }
            //print(photos.count)
            //print("Photos \(photos)")
            
            guard let photosArrayOfDicts = photos["photo"] as? [[String: AnyObject]] else {
                print("Unable to get photos key")
                return
            }
            //print(photosArrayOfDicts[0])
            print("Count of photos returned: \(photosArrayOfDicts.count)")
            
            if photosArrayOfDicts.count == 0 {
                print("No photos Found. Search Again.")
                completionHandler(result: nil, error: "No photos Found")
                return
            } else {
                for photoDictionary in photosArrayOfDicts {
                    guard let imageUrlString = photoDictionary["url_m"] as? String else {
                        print("Could not find key: url_m")
                        return
                    }
                    
                    let photo = Photo(imageUrl: imageUrlString, context: sharedInstance().sharedContext)
                    photo.pin = pin 
                    photosToReturn.append(photo)
                }
            }
            
        }
    
        completionHandler(result: photosToReturn, error: nil)
    }

    func taskForImageWithUrl(url: String, completionHandler: (imageData: NSData?, error: NSError?) -> Void) -> NSURLSessionTask {
        
        let url = NSURL(string: url)!
        
        let request = NSURLRequest(URL: url)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
            
            guard (error == nil) else {
                print("There was an error with the task for image")
                return 
            }
            
            guard let imageData = data else {
                print("Returning error to completion handler")
                completionHandler(imageData: nil, error: error)
                return
            }
            completionHandler(imageData: imageData, error: nil)
        }
        task.resume()
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
