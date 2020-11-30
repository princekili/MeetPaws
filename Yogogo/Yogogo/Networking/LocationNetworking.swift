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
    
    static let database = Firestore.firestore()
    
    static func startUpdatingUserLocation() {
        LocationNetworking.mapTimer = Timer(timeInterval: 10,
                                     target: self,
                                     selector: #selector(LocationNetworking.updateCurrentLocation),
                                     userInfo: nil,
                                     repeats: true)
        
        RunLoop.current.add(LocationNetworking.mapTimer, forMode: RunLoop.Mode.common)
    }
    
    @objc static func updateCurrentLocation() {
        guard CurrentUser.isMapLocationEnabled ?? false else { return }
        guard let currentLocation = LocationNetworking.map.userLocation?.coordinate else { return }
        
        let ref = database.collection("userLocation").document(CurrentUser.uid)
        let value = ["longitude": currentLocation.longitude, "latitude": currentLocation.latitude]
        
        ref.updateData(value)
    }
}
