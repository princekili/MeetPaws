//
//  ViewController.swift
//  Yogogo
//
//  Created by prince on 2020/11/28.
//
//  MapsVC is responsible for showing location of online users.

import UIKit
import Mapbox

class MapsViewController: UIViewController {
    
    var mapView: MGLMapView?
    
    let mapNetworking = MapsNetworking()
    
    var isUserSelected = false
    
    var selectedUser: User?
    
    var userCoordinates = [String: CLLocationCoordinate2D]()
    
    var userInfoTab: UserInfoTab?
    
//    var settingsButton: MapSettingsButton!
    
//    let point = MGLPointAnnotation()

    // MARK: -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        checkStatus()
        setupMapView()
        userMapHandler()
        
        // MARK: - For test
//        getUsers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        mapNetworking.mapsVC = self
//        mapNetworking.observeUserLocation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    // MARK: -
    
    func setupMapView() {
        let mapView = MGLMapView(frame: view.bounds)
        
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.delegate = self
        mapView.allowsRotating = false
        mapView.logoView.isHidden = true
        mapView.styleURL = URL(string: "mapbox://styles/mapbox/streets-v11")
        
        // Enable heading tracking mode so that the arrow will appear.
        mapView.userTrackingMode = .followWithHeading
        
        // Enable the permanent heading indicator, which will appear when the tracking mode is not `.followWithHeading`.
        mapView.showsUserHeadingIndicator = true
        
        self.mapView = mapView
        
        view.addSubview(mapView)
    }
    
    private func userMapHandler() {
        if !LocationNetworking.mapTimer.isValid {
            LocationNetworking.map.showsUserLocation = true
            LocationNetworking.startUpdatingUserLocation()
        }
    }
    
    // MARK: - Check user authorization of location
    
    private func deniedAlert() {
        let message = "To see the map you need to change your location settings. Please go to Settings/Yogogo/Location/ and allow location access.(While Using the App)"
        
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default) { (alertAction) in
            self.navigationController?.popViewController(animated: true)
        }
        
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
    
    // TBD
//    private func checkStatus() {
//        switch CLLocationManager.authorizationStatus() {
//        case .authorizedWhenInUse:
//            setupMapView()
//        case .denied:
//            deniedAlert()
//            CLLocationManager().requestWhenInUseAuthorization()
//        default:
//            break
//        }
//    }
//
//    // TBD
//    func mapView(_ mapView: MGLMapView, didChangeLocationManagerAuthorization manager: MGLLocationManager) {
//        if #available(iOS 14.0, *) {
//
//                switch manager.authorizationStatus {
//                    case .authorizedAlways, .authorizedWhenInUse:
//                        setupMapView()
//                    case .notDetermined, .denied, .restricted:
//                        deniedAlert()
//                    default:
//                        break
//                }
//            }
//    }
    
    // MARK: - For test
    
    var users = [User]()
    
//    private func getUsers() {
//        UserListNetworking().fetchUsers { (usersList) in
//            let sortedUserList = Array(usersList.values).sorted { (friend1, friend2) -> Bool in
//                return friend1.username ?? "" < friend2.username ?? ""
//            }
//            self.users = sortedUserList
//        }
//    }
}
