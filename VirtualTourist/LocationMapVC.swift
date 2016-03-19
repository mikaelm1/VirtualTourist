//
//  LocationMapVC.swift
//  VirtualTourist
//
//  Created by Mikael Mukhsikaroyan on 2/29/16.
//  Copyright © 2016 msquared. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class LocationMapVC: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var map: MKMapView!
    
    let latKey = "latitude"
    let lonKey = "longitude"
    
    var pins = [Pin]()
    
    lazy var sharedContext: NSManagedObjectContext = {
        CoreDataStackManager.sharedInstance().managedObjectContext!
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMap()
        pins = fetchAllPins()
        dropAllPins()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        removeAllPins()
        dropAllPins()
    }
    
    override func viewWillDisappear(animated: Bool) {
        print("View will dissapear")
        super.viewWillDisappear(animated)
        
    }
    
    
    func dropPin(gestureRecognizer: UIGestureRecognizer) {
        
        if gestureRecognizer.state == .Began {
            print("Dropped Pin")
            let touchPoint = gestureRecognizer.locationInView(map)
            let coordinate = map.convertPoint(touchPoint, toCoordinateFromView: map)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            
            let pin = Pin(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude, context: sharedContext)
            pins.append(pin)
            
            searchPhotos(coordinate.latitude, lon: coordinate.longitude, pin: pin)
            saveContext()
            map.addAnnotation(annotation)
        }
        
    }
    
    func dropAllPins() {
        print("Dropping saved pins, pin count: \(pins.count)")
        for pin in pins {
            
            let coordinate = CLLocationCoordinate2DMake(pin.latitude, pin.longitude)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            
            map.addAnnotation(annotation)
        }
    }
    
    func removeAllPins() {
        print("Removing annotations")
        map.removeAnnotations(map.annotations)
    }
    
    func searchPhotos(lat: Double, lon: Double, pin: Pin) {
        print("SearchPhotos in Map")
        Flickr.sharedInstance().taskForLocation(lat, longitude: lon) { (result, error) -> Void in
            
            if let parsedResult = result {
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
                    return
                } else {
                    
                    self.downloadImages(photosArrayOfDicts, forPin: pin)
                }
                
            }
        }
    }
    
    func downloadImages(photoDictionaries: [[String: AnyObject]], forPin: Pin) {
        
        print("Downlooding images")
        for photoDictionary in photoDictionaries {
            guard let imageUrlString = photoDictionary["url_m"] as? String else {
                print("Could not find key: url_m")
                return
            }
            print("Got image url")
            Flickr.sharedInstance().taskForImageWithUrl(imageUrlString, completionHandler: { (imageData, error) -> Void in
                if let imageData = imageData {
                    performUIUpdatesOnMain({ () -> Void in
                        let photo = Photo(imageUrl: imageUrlString, imageData: imageData, context: self.sharedContext)
                        photo.pin = forPin
                        print("Created photo")
                        //photo.pin = pin
                        //pin.photos.append(photo)
                    })
                    
                }
            })
        }
    }
    
    func setupMap() {
        map.delegate = self
        
        let uilpgr = UILongPressGestureRecognizer(target: self, action: "dropPin:")
        uilpgr.minimumPressDuration = 1.5
        map.addGestureRecognizer(uilpgr)
        
        let latitude = NSUserDefaults.standardUserDefaults().doubleForKey(latKey)
        let longitude = NSUserDefaults.standardUserDefaults().doubleForKey(lonKey)
        
        let latDelta: CLLocationDegrees = 0.2 // the smaller the more zoomed in
        let lonDelta: CLLocationDegrees = 0.2
        
        let span = MKCoordinateSpanMake(latDelta, lonDelta)
        let location = CLLocationCoordinate2DMake(latitude, longitude)
        let region = MKCoordinateRegionMake(location, span)
        map.setRegion(region, animated: false)
    }
    
    // MARK: - Core Data Convenience
    
    func saveContext() {
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    func fetchAllPins() -> [Pin] {
        print("Fetching pins")
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        
        do {
            return try sharedContext.executeFetchRequest(fetchRequest) as! [Pin]
        } catch {
            print("Error in fetching Pins")
            return [Pin]()
        }
    }
    
    // MARK: - Map View Delegate
    
    func saveMapLocation() {
        
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        //print("Region changed")
        // Called whenever the view or zoom level changes
        let region = map.region.center
        //let span = map.region.span
        //print("Region: \(region)")
        //print("Span: \(span)")
        
        NSUserDefaults.standardUserDefaults().setDouble(region.latitude, forKey: latKey)
        NSUserDefaults.standardUserDefaults().setDouble(region.longitude, forKey: lonKey)
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        print("Selected pin")
        
        let controller = storyboard!.instantiateViewControllerWithIdentifier("PhotoAlbumCollectionVC") as! PhotoAlbumCollectionVC
        
        for pin in pins {
            if pin.latitude == view.annotation!.coordinate.latitude {
                controller.pin = pin
                print("The pin to send: \(pin.latitude)")
            }
        }
        
        presentViewController(controller, animated: true, completion: nil)
    }
    
    
    
    
    
    
    
    



}
