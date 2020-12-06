//
//  EditProfileTableViewController.swift
//  Yogogo
//
//  Created by prince on 2020/12/5.
//

import UIKit

class EditProfileTableViewController: UITableViewController {
    
    @IBOutlet weak var profileImage: UIImageView! {
        didSet {
            profileImage.layer.cornerRadius = 50
        }
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var bioLabel: UILabel!
    
    var imagePickerController: UIImagePickerController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func doneButtonDidTap(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonDidTap(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Pass data via closure
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "" {
            
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 4
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        imagePickerController = UIImagePickerController()
        imagePickerController?.delegate = self
        imagePickerController?.allowsEditing = true
        
        switch indexPath.row {
        
        case 0:
            // UIAlertController
            let imagePickerAlertController = UIAlertController(title: "", message: "Select a Photo", preferredStyle: .actionSheet)
            
            // UIAlertAction
            let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
                
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    
                    self.imagePickerController?.sourceType = .camera
                    
                    self.present(self.imagePickerController!, animated: true, completion: nil)
                }
            }
            
            let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { _ in
                
                if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                    
                    self.imagePickerController?.sourceType = .photoLibrary
                    
                    self.present(self.imagePickerController!, animated: true, completion: nil)
                }
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                
                imagePickerAlertController.dismiss(animated: true, completion: nil)
            }
            
            // addAction
            imagePickerAlertController.addAction(cameraAction)
            imagePickerAlertController.addAction(photoLibraryAction)
            imagePickerAlertController.addAction(cancelAction)
            
            // for iPad
            if let popoverController = imagePickerAlertController.popoverPresentationController {
                
                if let cell = tableView.cellForRow(at: indexPath) {
                    
                    popoverController.sourceView = cell
                    popoverController.sourceRect = cell.bounds
                }
            }
            present(imagePickerAlertController, animated: true, completion: nil)
            
        case 1:
            
            if let nextC = self.storyboard?.instantiateViewController(identifier: "EditNameNC") {
                nextC.modalPresentationStyle = .fullScreen
                self.present(nextC, animated: true, completion: nil)
            }
//
//        case 2:
//
//        case 3:
            
        default:
            return
        }
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension EditProfileTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
 
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
//        if let selectedImage = info[.originalImage] as? UIImage {
        if let selectedImage = info[.editedImage] as? UIImage {
            
            profileImage.image = selectedImage
            profileImage.contentMode = .scaleAspectFill
            profileImage.clipsToBounds = true
        }
        dismiss(animated: true, completion: nil)
    }
}
