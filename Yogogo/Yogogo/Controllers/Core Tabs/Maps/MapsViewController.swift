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
    
    @objc let goButton = UIButton()
    
//    var settingsButton: MapSettingsButton!
    
//    let point = MGLPointAnnotation()

    // MARK: -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        checkStatus()
        setupMapView()
        userMapHandler()
        setupGoButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        mapNetworking.mapsVC = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    // MARK: - setup MapView
    
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
    
    // MARK: - setup StartButton
    
    private func setupGoButton() {
        view.addSubview(goButton)
        
        let size: CGFloat = 70
        let image = UIImage(named: "go_yellow")
        goButton.setImage(image, for: .normal)
        goButton.contentMode = .scaleAspectFill
        goButton.backgroundColor = .white
        goButton.clipsToBounds = true
        goButton.layer.cornerRadius = size / 2
        goButton.layer.borderWidth = 3
        goButton.layer.borderColor = UIColor.white.cgColor
        goButton.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = [
            goButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            goButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 280),
            goButton.widthAnchor.constraint(equalToConstant: size),
            goButton.heightAnchor.constraint(equalToConstant: size)
        ]
        NSLayoutConstraint.activate(constraints)
        
        goButton.addTarget(self, action: #selector(goButtonDidTap), for: .touchUpInside)
    }
    
    @objc private func goButtonDidTap() {
        mapNetworking.observeUsers { [weak self] userIds in
            
            for userId in userIds {
                self?.mapNetworking.getUserInfo(userId: userId) { [weak self] (userId, values) in
                    
                    self?.mapNetworking.decodeUser(userId: userId, values: values) { [weak self] user in
                        
                        self?.mapNetworking.observeUserLocation(user: user)
                    }
                }
            }
        }
    }

    // MARK: - user Map Handler
    
    private func userMapHandler() {
        if !LocationNetworking.mapTimer.isValid {
            LocationNetworking.map.showsUserLocation = true
            LocationNetworking.startUpdatingUserLocation()
        }
    }
    
    // MARK: - show nextVC
    
    @objc func showMyProfileVC() {
        let storyboard = UIStoryboard(name: StoryboardName.main.rawValue, bundle: nil)
        let myProfileVC = storyboard.instantiateViewController(identifier: StoryboardId.myProfileVC.rawValue)
        
        present(myProfileVC, animated: true, completion: nil)
    }
    
    @objc func showUserProfileVC() {
        let storyboard = UIStoryboard(name: StoryboardName.main.rawValue, bundle: nil)
        let userProfileVC = storyboard.instantiateViewController(identifier: StoryboardId.userProfileVC.rawValue)
        
        present(userProfileVC, animated: true, completion: nil)
    }
}

// MARK: - Check user authorization of location

extension MapsViewController {
    
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
}
