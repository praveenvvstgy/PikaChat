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
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 100
    }
    
    func startLocationCollection() {
        locationManager.startUpdatingLocation()
    }
    
    func stopLocationCollection() {
        locationManager.stopUpdatingLocation()
    }
    
    func collectLocationOnce() {
        locationManager.requestLocation()
    }
    
    func showLocationPrompt() {
        let pscope = PermissionScope(backgroundTapCancels: false)
        pscope.closeButton.hidden = true
        pscope.addPermission(LocationWhileInUsePermission(), message: "We use this to find messages near you \nand attach your location to your posts")
        pscope.show({ finished, results in
            print("got results \(results)")
            self.collectLocationOnce()
            }, cancelled: { (results) -> Void in
                print("thing was cancelled")
        })
    }

    
}

extension LocationHelper: CLLocationManagerDelegate {
    
    @objc func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if (currentLocation == nil && manager.location != nil) || (manager.location != nil  && currentLocation.distanceFromLocation(manager.location!) > 100) {
            print("Location changed to: \(manager.location)")
            NSNotificationCenter.defaultCenter().postNotificationName("locationChanged", object: manager.location)
        }
        currentLocation = manager.location
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error.localizedDescription)
    }
    
}