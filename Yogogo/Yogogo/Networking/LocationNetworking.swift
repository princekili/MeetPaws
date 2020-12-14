//
//  LocationKit.swift
//  Yogogo
//
//  Created by prince on 2020/11/29.
//

import UIKit
import Firebase
import Mapbox

class LocationNetworking {
    
    static var mapTimer = Timer()
    
    static var map = MGLMapView()
    
    static let userManager = UserManager.shared
    
    static func startUpdatingUserLocation() {
        
        LocationNetworking.mapTimer = Timer(timeInterval: 5,
                                     target: self,
                                     selector: #selector(LocationNetworking.updateCurrentLocation),
                                     userInfo: nil,
                                     repeats: true)
        
        RunLoop.current.add(LocationNetworking.mapTimer, forMode: RunLoop.Mode.common)
    }
    
    // Update my location
    @objc static func updateCurrentLocation() {
        
        guard userManager.currentUser?.isMapLocationEnabled ?? false else { return }
        guard let currentLocation = LocationNetworking.map.userLocation?.coordinate else { return }
        
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference().child("userLocations").child(userId)
        let values = ["longitude": currentLocation.longitude, "latitude": currentLocation.latitude]
        
        ref.updateChildValues(values)
    }
}
