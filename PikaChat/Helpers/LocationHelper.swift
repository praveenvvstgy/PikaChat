//
//  LocationHelper.swift
//  PikaChat
//
//  Created by Praveen Gowda I V on 7/26/16.
//  Copyright © 2016 Gowda I V, Praveen. All rights reserved.
//

import Foundation
import CoreLocation
import PermissionScope

class LocationHelper: NSObject {
    
    static let sharedHelper = LocationHelper()
    
    var currentLocation: CLLocation!
    let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.startUpdatingLocation()
    }
    
    func startCollectingLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.startUpdatingLocation()
    }
    
    func showLocationPrompt() {
        let pscope = PermissionScope(backgroundTapCancels: false)
        pscope.closeButton.hidden = true
        pscope.addPermission(LocationWhileInUsePermission(), message: "We use this to find messages near you \nand attach your location to your posts")
        pscope.show({ finished, results in
            print("got results \(results)")
            LocationHelper.sharedHelper.startCollectingLocation()
            }, cancelled: { (results) -> Void in
                print("thing was cancelled")
        })
    }

    
}

extension LocationHelper: CLLocationManagerDelegate {
    
    @objc func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if manager.location != nil && currentLocation != nil  && currentLocation.distanceFromLocation(manager.location!) > 100 {
            print("Location changed to: \(manager.location)")
            NSNotificationCenter.defaultCenter().postNotificationName("locationChanged", object: manager.location)
        }
        currentLocation = manager.location
    }
    
}