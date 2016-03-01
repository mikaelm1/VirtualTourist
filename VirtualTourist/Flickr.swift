//
//  Flickr.swift
//  VirtualTourist
//
//  Created by Mikael Mukhsikaroyan on 2/29/16.
//  Copyright © 2016 msquared. All rights reserved.
//

import UIKit

class Flickr {
    
    let session = NSURLSession.sharedSession()
    
    //  https:api.flickr.com/services/rest/?method=flickr.photos.search&api_key=88569b3c55687dd564daf5dca5234002&lat=34&lon=-118&format=json&nojsoncallback=1&auth_token=72157662933309284-7a0c20512f3f9569&api_sig=8cbb9c5524e1e03fc71dbbbf492ac218
    
    func searchByLatLon(latitude: Double, longitude: Double, completionHandlerForLatLon: (result: [String: AnyObject]?, error: String?) -> Void) {
        print("Search by Lat Lon")
                
        let url = NSURL(string: "https:api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(Constants.APIKey)&lat=34&lon=-118&format=json&nojsoncallback=1")!
        
        let request = NSMutableURLRequest(URL: url)
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            
            func sendError(error: String) {
                print(error)
            }
            
            guard (error == nil) else {
                sendError("There was an error with the request")
                return
            }
            
            guard let data = data else {
                sendError("No data was returned")
                return
            }
            
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                sendError("Unable to parse into JSON")
                return
            }
            print(parsedResult)
            //completionHandlerForLatLon(result: parsedResult, error: nil)
            
        // end of closure
        }
        task.resume()
    }
    
    // MARK: Shared Instance
    class func sharedInstance() -> Flickr {
        struct Singleton {
            static var sharedInstance = Flickr()
        }
        return Singleton.sharedInstance
    }
}
