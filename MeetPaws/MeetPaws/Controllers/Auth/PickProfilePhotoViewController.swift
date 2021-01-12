//
//  PickProfilePhotoViewController.swift
//  MeetPaws
//
//  Created by prince on 2020/12/8.
//

import UIKit
import Firebase

class PickProfilePhotoViewController: UIViewController {

    @IBOutlet weak var profilePhotoImageView: UIImageView! {
        didSet {
            profilePhotoImageView.layer.cornerRadius = profilePhotoImageView.frame.size.width / 2
            profilePhotoImageView.contentMode = .scaleAspectFill
            profilePhotoImageView.enableTapAction(sender: self, selector: #selector(selectPhoto))
        }
    }
    
    @IBOutlet weak var okButton: UIButton! {
        didSet {
            okButton.layer.cornerRadius = 8
            okButton.layer.masksToBounds = true
        }
    }
    
    var imagePickerController: UIImagePickerController?
    
    let userManager = UserManager.shared
    
    // MARK: -
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: -
    
    @IBAction func selectPhotoButtonDidTap(_ sender: UIButton) {
        selectPhoto()
    }

    @IBAction func okButtonDidTap(_ sender: UIButton) {
        okButton.isEnabled = false
        addUser()
    }
    
    // MARK: - Upload data to add a new user
    
    private func addUser() { 
        // Save data
        let username = userManager.username
        
        guard let image = profilePhotoImageView.image else {
            // Show alert
            print("------ Please select a profile photo! ------")
            return
        }
        
        userManager.addUser(image: image) { [weak self] in
            print("------ Upload new added user '\(username)' data successfully! ------")
            self?.showMainView()
        }
    }
    
    private func showMainView() {
        let storyboard = UIStoryboard(name: StoryboardName.main.rawValue, bundle: nil)
        let nextController = storyboard.instantiateViewController(withIdentifier: StoryboardId.tabBarController.rawValue)
        nextController.modalPresentationStyle = .fullScreen
        present(nextController, animated: true, completion: nil)
        
        SceneDelegate().window?.rootViewController = nextController
    }
    
    // MARK: - Select a Photo
    
    @objc private func selectPhoto() {
        imagePickerController = UIImagePickerController()
        imagePickerController?.delegate = self
        imagePickerController?.allowsEditing = true
        
        // UIAlertController
        let imagePickerAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
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
        
        present(imagePickerAlertController, animated: true, completion: nil)
    }
}

extension PickProfilePhotoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
 
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        if let selectedImage = info[.editedImage] as? UIImage {
            
            profilePhotoImageView.image = selectedImage
            profilePhotoImageView.contentMode = .scaleAspectFill
            profilePhotoImageView.clipsToBounds = true
        }
        dismiss(animated: true, completion: nil)
    }
}
