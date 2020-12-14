//
//  SceneDelegate.swift
//  Yogogo
//
//  Created by prince on 2020/11/26.
//

import UIKit
import Firebase

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    let userManager = UserManager.shared
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
//        guard let _ = (scene as? UIWindowScene) else { return }
        
        // MARK: - Determine the Initial Page
        
        guard let sceneWindow = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: sceneWindow)
        
        if Auth.auth().currentUser?.uid != nil {
            print("------ Auth.auth().currentUser?.uid != nil ------")
            showNextVC(sceneWindow)
        } else {
            print("------ Auth.auth().currentUser?.uid == nil ------")
            showSignInVC(sceneWindow)
        }
    }
    
    // MARK: -

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }

}

extension SceneDelegate {
    
    func showNextVC(_ sceneWindow: UIWindowScene) {
        userManager.checkFirstTimeSignIn { (isFirstTime) in
            if isFirstTime == true {
                print("------ isFirstTime = true ------")
                self.showPickUsernameVC(sceneWindow)
            } else {
                print("------ isFirstTime = false ------")
                self.showMainView(sceneWindow)
            }
        }
    }
    
    func showMainView(_ sceneWindow: UIWindowScene) {
        let storyboard = UIStoryboard(name: StoryboardName.main.rawValue, bundle: nil)
        let initialVC = storyboard.instantiateViewController(withIdentifier: StoryboardId.tabBarController.rawValue)
        
        window = UIWindow(windowScene: sceneWindow)
        window?.rootViewController = initialVC
        window?.makeKeyAndVisible()
    }
    
    func showSignInVC(_ sceneWindow: UIWindowScene) {
        let storyboard = UIStoryboard(name: StoryboardName.auth.rawValue, bundle: nil)
        let initialVC = storyboard.instantiateViewController(withIdentifier: StoryboardId.signInVC.rawValue)
        
        window = UIWindow(windowScene: sceneWindow)
        window?.rootViewController = initialVC
        window?.makeKeyAndVisible()
    }
    
    func showPickUsernameVC(_ sceneWindow: UIWindowScene) {
        let storyboard = UIStoryboard(name: StoryboardName.auth.rawValue, bundle: nil)
        let initialVC = storyboard.instantiateViewController(withIdentifier: StoryboardId.pickUsernameVC.rawValue)
        initialVC.modalPresentationStyle = .fullScreen
        
        window = UIWindow(windowScene: sceneWindow)
        window?.rootViewController = initialVC
        window?.makeKeyAndVisible()
    }
}
