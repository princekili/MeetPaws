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
    
    let goButton = UIButton()
    
    var isMapLocationEnabled = UserManager.shared.currentUser?.isMapLocationEnabled ?? false
        
//    var settingsButton: MapSettingsButton!
    
//    let point = MGLPointAnnotation()

    // MARK: -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMapView()
        userMapHandler()
        setupGoButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        mapNetworking.mapsVC = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SegueMapsToUserProfile" {
            guard let userProfileVC = segue.destination as? UserProfileViewController else { return }
            // Pass user data to userProfileVC
            userProfileVC.user = self.selectedUser
        }
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
    
    // MARK: - setup GoButton
    
    private func setupGoButton() {
        view.addSubview(goButton)
        
        let image = isMapLocationEnabled ? UIImage(named: "stop_red") : UIImage(named: "go_yellow")
        goButton.setImage(image, for: .normal)
        goButton.contentMode = .scaleAspectFill
        goButton.backgroundColor = .white
        
        let size: CGFloat = 70
        goButton.layer.cornerRadius = size / 2
        goButton.layer.borderWidth = 3
        goButton.layer.borderColor = UIColor.white.cgColor
        goButton.clipsToBounds = true
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
        
        isMapLocationEnabled.toggle()
        UserManager.shared.currentUser?.isMapLocationEnabled = isMapLocationEnabled
        UserManager.shared.updateIsMapLocationEnabled()
        
        // GO <--> STOP
        setupGoButton()
        
        // Check
        guard isMapLocationEnabled else {
            mapNetworking.removeAllAnnotations()
            return
        }
        
        // Get all userIds
        mapNetworking.observeUsers { [weak self] userIds in
            
            for userId in userIds {
                
                // Get user's info - Step.1
                self?.mapNetworking.getUserInfo(userId: userId) { [weak self] (userId, values) in
                    
                    // Get user's info - Step.2
                    self?.mapNetworking.decodeUser(userId: userId, values: values) { [weak self] user in
                        
                        // Check user's isMapLocationEnabled & Handle user's location
                        self?.mapNetworking.observeUserLocation(user: user)
                    }
                }
            }
        }
    }

    // MARK: - user Map Handler
    
    private func userMapHandler() {
        if !MapsNetworking.mapTimer.isValid {
            MapsNetworking.map.showsUserLocation = true
            MapsNetworking.startUpdatingUserLocation()
        }
    }
    
    // MARK: - show nextVC
    
    @objc func showMyProfileVC() {
        let storyboard = UIStoryboard(name: StoryboardName.main.rawValue, bundle: nil)
        let myProfileVC = storyboard.instantiateViewController(identifier: StoryboardId.myProfileVC.rawValue)
        
        navigationController?.pushViewController(myProfileVC, animated: true)
    }
    
    @objc func showUserProfileVC() {
        
        performSegue(withIdentifier: "SegueMapsToUserProfile", sender: nil)
    }
}

// MARK: User location annotation

extension MapsViewController: MGLMapViewDelegate {
    
    // Substitute our custom view for the user location annotation.
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        
        // Me
        if annotation is MGLUserLocation && mapView.userLocation != nil {
//            return CustomUserLocationAnnotationView()
            return CurrentUserAnnotationView()
            
        // Other users
        } else {
            guard let annotation = annotation as? AnnotationPin else { return nil }
            let reuseIdentifier = "UserAnnotation"
            return UserAnnotationView(annotation: annotation,
                                      reuseIdentifier: reuseIdentifier,
                                      user: annotation.user)
        }
    }
    
    // MARK: - didSelect - tap the user location annotation to toggle heading tracking mode.
    
    func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
        
        mapView.setCenter(annotation.coordinate, zoomLevel: 16, animated: true)
        
        tabBarController?.tabBar.isHidden = true
        
        // Me
        if annotation is MGLUserLocation && mapView.userLocation != nil {
            
            if mapView.userTrackingMode != .followWithHeading {
                mapView.userTrackingMode = .followWithHeading
            } else {
                mapView.resetNorth()
            }
            
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           usingSpringWithDamping: 0.7,
                           initialSpringVelocity: 1,
                           options: .curveEaseIn,
                           animations: {
                            
                self.userInfoTab = UserInfoTab(annotation: annotation)
                            
                let tapGesture = UITapGestureRecognizer(target: self,
                                                        action: #selector(self.showMyProfileVC))
                self.userInfoTab?.addGestureRecognizer(tapGesture)
                            
                self.userInfoTab?.actionButton.addTarget(self,
                                                         action: #selector(self.showMyProfileVC),
                                                         for: .touchUpInside)
                            
                self.view.addSubview(self.userInfoTab!)
            })
            
        // Other users
        } else {
            guard let annotation = annotation as? AnnotationPin else { return }
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           usingSpringWithDamping: 0.7,
                           initialSpringVelocity: 1,
                           options: .curveEaseIn,
                           animations: {
                            
                self.userInfoTab = UserInfoTab(annotation: annotation)
                let tapGesture = UITapGestureRecognizer(target: self,
                                                        action: #selector(self.showUserProfileVC))
                self.selectedUser = annotation.user
                self.userInfoTab?.addGestureRecognizer(tapGesture)
                self.userInfoTab?.actionButton.addTarget(self,
                                                         action: #selector(self.showUserProfileVC),
                                                         for: .touchUpInside)
                self.view.addSubview(self.userInfoTab!)
            })
        }
    }
    
    // MARK: - didDeselect
    
    func mapView(_ mapView: MGLMapView, didDeselect annotation: MGLAnnotation) {
        self.userInfoTab?.removeFromSuperview()
        self.userInfoTab = nil
        
        tabBarController?.tabBar.isHidden = false
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
