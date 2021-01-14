//
//  SettingsTableViewController.swift
//  MeetPaws
//
//  Created by prince on 2020/12/5.
//

import UIKit
import FirebaseAuth

class SettingsTableViewController: UITableViewController {
    
    let segueId = "SegueAboutDeveloper"

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backButtonTitle = ""
    }
    
    private func handleSignOut() {
        print("Sign Out button did tap.")
        
        do {
            try Auth.auth().signOut()
            
        } catch {
            let alertController = UIAlertController(title: "Sign Out Error",
                                                    message: error.localizedDescription,
                                                    preferredStyle: .alert)
            
            let okayAction = UIAlertAction(title: "OK",
                                           style: .cancel,
                                           handler: nil)
            
            alertController.addAction(okayAction)
            present(alertController, animated: true, completion: nil)
            
            return
        }
        
        showSignInVC()
    }
    
    private func showSignInVC() {
        let storyboard = UIStoryboard(name: StoryboardName.auth.rawValue, bundle: nil)
        let nextController = storyboard.instantiateViewController(identifier: StoryboardId.signInVC.rawValue)
        
        nextController.modalPresentationStyle = .fullScreen
        present(nextController, animated: true, completion: nil)
        SceneDelegate().window?.rootViewController = nextController
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return 1
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        if indexPath.section == 0 && indexPath.row == 0 {
            performSegue(withIdentifier: segueId, sender: nil)
        }
        
        if indexPath.section == 1 && indexPath.row == 0 {
            handleSignOut()
        }
    }
}
