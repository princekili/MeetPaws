//
//  EditProfileTableViewController.swift
//  Yogogo
//
//  Created by prince on 2020/12/5.
//

import UIKit

class EditProfileTableViewController: UITableViewController {
    
    let userManager = UserManager.shared
    
    @IBOutlet weak var profileImage: UIImageView! {
        didSet {
            profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
            profileImage.contentMode = .scaleAspectFill
            
            guard let image = userManager.currentUser?.profileImage else { return }
            let url = URL(string: image)
            profileImage.kf.setImage(with: url)
        }
    }
    
    @IBOutlet weak var nameLabel: UILabel! {
        didSet {
            nameLabel.text = userManager.currentUser?.fullName
        }
    }
    
    @IBOutlet weak var usernameLabel: UILabel! {
        didSet {
            usernameLabel.text = userManager.currentUser?.username
        }
    }
    
    @IBOutlet weak var bioTextView: UITextView! {
        didSet {
            bioTextView.text = userManager.currentUser?.bio
        }
    }
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    var imagePickerController: UIImagePickerController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func doneButtonDidTap(_ sender: UIBarButtonItem) {
        doneButton.isEnabled = false

        guard let profileImage = profileImage.image else { return }
        guard let fullName = nameLabel.text else { return }
        guard let username = usernameLabel.text else { return }
        guard let bio = bioTextView.text else { return }
        
//        userManager.updateUserProfile(image: profileImage, fullName: fullName, username: username, bio: bio) { [weak self] in
        userManager.updateUserProfile(image: profileImage, fullName: fullName, username: username, bio: bio) {
//            print("------ Print currentUser in UserManager ------")
//            print(self.userManager.currentUser ?? "------ currentUser == nil ------")
//            print("------------")
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonDidTap(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Update user info
    
    private func updateUserInfo() {
        
    }
    
    // MARK: - show next VC
    
    private func showEditNameVC() {
        if let nextVC = self.storyboard?.instantiateViewController(identifier: "EditNameVC") as? EditNameViewController {
            
            nextVC.text = nameLabel.text
            nextVC.tapHandler = { [weak self] textInput in
                self?.nameLabel.text = textInput
            }
            
            nextVC.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
    }
    
    private func showEditUsernameVC() {
        if let nextVC = self.storyboard?.instantiateViewController(identifier: "EditUsernameVC") as? EditUsernameViewController {
            
            nextVC.text = usernameLabel.text
            nextVC.tapHandler = { [weak self] textInput in
                self?.usernameLabel.text = textInput
            }
            
            nextVC.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
    }
    
    private func showEditBioVC() {
        if let nextVC = self.storyboard?.instantiateViewController(identifier: "EditBioVC") as? EditBioViewController {
            
            nextVC.text = bioTextView.text
            nextVC.tapHandler = { [weak self] textInput in
                self?.bioTextView.text = textInput
            }
            
            nextVC.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
            
            // for iPad
            if let popoverController = imagePickerAlertController.popoverPresentationController {
                
                if let cell = tableView.cellForRow(at: indexPath) {
                    
                    popoverController.sourceView = cell
                    popoverController.sourceRect = cell.bounds
                }
            }
            present(imagePickerAlertController, animated: true, completion: nil)
            
        case 1:
            showEditNameVC()

        case 2:
            showEditUsernameVC()

        case 3:
            showEditBioVC()
            
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
