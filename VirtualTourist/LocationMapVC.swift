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
        map.delegate = self
        setupMap()

    }
    
    func dropPin(gestureRecognizer: UIGestureRecognizer) {
        let touchPoint = gestureRecognizer.locationInView(map)
        let coordinate = map.convertPoint(touchPoint, toCoordinateFromView: map)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        
        map.addAnnotation(annotation)
    }
    
    func setupMap() {
        let uilpgr = UILongPressGestureRecognizer(target: self, action: "dropPin:")
        uilpgr.minimumPressDuration = 1.0
        map.addGestureRecognizer(uilpgr)
    }



}
