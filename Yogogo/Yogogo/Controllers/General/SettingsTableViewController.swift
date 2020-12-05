//
//  SettingsTableViewController.swift
//  Yogogo
//
//  Created by prince on 2020/12/5.
//

import UIKit
import FirebaseAuth

class SettingsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
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
        
        // Show Sign in page
        let storyboard = UIStoryboard(name: "Auth", bundle: nil)
        let nextController = storyboard.instantiateViewController(identifier: "SignInVC")
        
        nextController.modalPresentationStyle = .fullScreen
        present(nextController, animated: true, completion: nil)
        SceneDelegate().window?.rootViewController = nextController
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        
        case 0: return 3
            
        case 1: return 1
            
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        if indexPath.section == 1 && indexPath.row == 0 {
            handleSignOut()
        }
    }
}
