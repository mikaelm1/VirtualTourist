//
//  LocationMapVC.swift
//  VirtualTourist
//
//  Created by Mikael Mukhsikaroyan on 2/29/16.
//  Copyright © 2016 msquared. All rights reserved.
//

import UIKit
import MapKit 

class LocationMapVC: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var map: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMap()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // TESTING
        searchPhotos()
    }
    
    override func viewWillDisappear(animated: Bool) {
        print("View will dissapear")
        super.viewWillDisappear(animated)
        
    }
    
    func searchPhotos() {
        print("SearchPhotos")
        Flickr.sharedInstance().searchByLatLon(118.0, longitude: -34.0) { (result, error) -> Void in
            
            print(result)
        }
    }
    
    
    func dropPin(gestureRecognizer: UIGestureRecognizer) {
        let touchPoint = gestureRecognizer.locationInView(map)
        let coordinate = map.convertPoint(touchPoint, toCoordinateFromView: map)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        
        map.addAnnotation(annotation)
    }
    
    func setupMap() {
        map.delegate = self
        
        let uilpgr = UILongPressGestureRecognizer(target: self, action: "dropPin:")
        uilpgr.minimumPressDuration = 1.0
        map.addGestureRecognizer(uilpgr)
        
        let latitude: CLLocationDegrees = 34.192
        let longitude: CLLocationDegrees = -118.439
        //let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        let latDelta: CLLocationDegrees = 0.2 // the smaller the more zoomed in
        let lonDelta: CLLocationDegrees = 0.2
        
        let span = MKCoordinateSpanMake(latDelta, lonDelta)
        let location = CLLocationCoordinate2DMake(latitude, longitude)
        let region = MKCoordinateRegionMake(location, span)
        //map.setCenterCoordinate(coordinate, animated: true)
        map.setRegion(region, animated: false)
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        //print("Region changed")
        // Called whenever the view or zoom level changes
        let region = map.region.center
        let span = map.region.span
        //print("Region: \(region)")
        //print("Span: \(span)")
    }
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        print("Updated User Location")
        //print(userLocation)
    }
    
    
    
    



}
