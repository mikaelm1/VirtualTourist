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
        
        // TESTING Purposes
        Flickr.sharedInstance().taskForLocation(118, longitude: 34) { (result, error) -> Void in
            
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
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
            
            searchPhotos(coordinate.latitude, lon: coordinate.longitude)
            
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
    
    func searchPhotos(lat: Double, lon: Double) {
        print("SearchPhotos in Map")
        Flickr.sharedInstance().taskForLocation(lat, longitude: lon) { (result, error) -> Void in
            
            performUIUpdatesOnMain({ () -> Void in
                if let imageDictionary = result {
                    //print("Got result \(imageDictionary.keys)")
                    
                    let pin = Pin(latitude: lat, longitude: lon, context: self.sharedContext)
                    self.pins.append(pin)
                    print("Pins count: \(self.pins.count)")
                    for (key, value) in imageDictionary {
                        //print("Key: \(key)")
                        //print("Value: \(value)")
                        let photo = Photo(imageUrl: key, imageData: value, context: self.sharedContext)
                        photo.pin = pin
                    }
                    self.saveContext()
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
