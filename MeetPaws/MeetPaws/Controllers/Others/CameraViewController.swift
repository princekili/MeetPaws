//
//  AddPostViewController.swift
//  MeetPaws
//
//  Created by prince on 2020/11/30.
//

import UIKit
import YPImagePicker
import AVFoundation
import AVKit
import Photos
import FirebaseDatabase

protocol LoadRecentPostsDelegate: AnyObject {
    
    func loadRecentPost()
}

class CameraViewController: UIViewController {
    
    var selectedItems = [YPMediaItem]()
    
    let selectedImageV = UIImageView()
    
    let pickButton = UIButton()
    
    let resultsButton = UIButton()
    
    weak var delegate: LoadRecentPostsDelegate?
    
    @IBOutlet weak var imageButton: UIButton!
    
    @IBOutlet weak var captionTextView: UITextView! {
        didSet {
            captionTextView.placeholder = "Write a caption..."
        }
    }
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showPicker()
        hideButtons()
        hideKeyboardWhenDidTapAround()
    }
    
    // MARK: - Upload Post
    
    @IBAction func shareButtonDidTap(_ sender: UIBarButtonItem) {
        shareButton.isEnabled = false
        
        guard let image = selectedItems.singlePhoto?.image else {
            dismiss(animated: true, completion: nil)
            WrapperProgressHUD.showFailed(with: "Failed")
            print("selectedItems error")
            return
        }
        let caption = captionTextView.text ?? ""
        
        PostManager.shared.uploadPost(image: image, caption: caption) { [weak self] in
            self?.delegate?.loadRecentPost()
        }
        self.dismiss(animated: true, completion: nil)
        WrapperProgressHUD.showSuccess()
    }
    
    // MARK: -
    
    @IBAction func cancelButtonDidTap(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func imageButtonDidTap(_ sender: UIButton) {
        showPicker()
    }
    
    private func hideButtons() {
        cancelButton.tintColor = .clear
        shareButton.tintColor = .clear
        imageButton.isHidden = true
        captionTextView.isHidden = true
    }
    
    private func showButtons() {
        cancelButton.tintColor = .label
        shareButton.tintColor = .systemBlue
        imageButton.isHidden = false
        captionTextView.isHidden = false
    }
    
    // MARK: - Show next Controller
    
    func showNextController() {
        if let nextC = self.storyboard?.instantiateViewController(identifier: "SubmitPostTVC") {
            nextC.modalTransitionStyle = .crossDissolve
            present(nextC, animated: true, completion: nil)
        }
    }
    
    // MARK: - Configuration
    @objc func showPicker() {
        var config = YPImagePickerConfiguration()
        config.library.onlySquare = true
        config.onlySquareImagesFromCamera = true
        config.targetImageSize = .cappedTo(size: 1024)
        config.library.mediaType = .photo
        config.library.itemOverlayType = .grid
        config.shouldSaveNewPicturesToAlbum = true
        config.video.compression = AVAssetExportPresetMediumQuality
        config.startOnScreen = .library
        config.screens = [.library, .photo]
        config.video.recordingTimeLimit = 15.0
        config.video.libraryTimeLimit = 15.0
        config.showsCrop = .none
        config.wordings.libraryTitle = "Library"
        config.hidesStatusBar = false
        config.hidesBottomBar = false
        config.maxCameraZoomFactor = 3.0
        config.library.maxNumberOfItems = 1
        config.gallery.hidesRemoveButton = false
        config.library.preselectedItems = selectedItems
        
        let picker = YPImagePicker(configuration: config)
        picker.imagePickerDelegate = self
        
        // MARK: didFinishPicking
        
        picker.didFinishPicking { [unowned picker] items, cancelled in
            
            if cancelled {
                print("Picker was canceled")
                self.hideButtons()
                picker.dismiss(animated: true, completion: nil)
                self.dismiss(animated: true, completion: nil)
                return
            }
            
            self.selectedItems = items
            self.imageButton.setImage(items.singlePhoto?.image, for: .normal)
            
            self.showButtons()
            
            picker.dismiss(animated: true, completion: nil)
        }

        present(picker, animated: true, completion: nil)
    }
}

// Support methods
extension CameraViewController {
    
    // MARK: - Observe Posts
    
    func observePosts() {
        let ref = PostManager.shared.postsRef
        ref.observeSingleEvent(of: .value) { (snapshot) in
            
            print("------ Total number of posts: \(snapshot.childrenCount) ------")
            
            guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else {
                print("------ There's no post. ------")
                return
            }
            
            for item in allObjects {
                let postInfo = item.value as? [String: Any] ?? [:]
                
                print("-------")
                print("Post ID: \(item.key)")
                print("userId: \(postInfo["userId"] ?? "")")
                print("username: \(postInfo["username"] ?? "")")
                print("Image URL: \(postInfo["imageFileURL"] ?? "")")
                print("userDidLike: \(postInfo["userDidLike"] ?? "")")
                print("caption: \(postInfo["caption"] ?? "")")
                print("Timestamp: \(postInfo["timestamp"] ?? "")")
            }
        }
    }
    
    // MARK: - Default
    
    /* Gives a resolution for the video by URL */
    func resolutionForLocalVideo(url: URL) -> CGSize? {
        guard let track = AVURLAsset(url: url).tracks(withMediaType: AVMediaType.video).first else { return nil }
        let size = track.naturalSize.applying(track.preferredTransform)
        return CGSize(width: abs(size.width), height: abs(size.height))
    }
}

// YPImagePickerDelegate
extension CameraViewController: YPImagePickerDelegate {
    func noPhotos() {}
    
    func shouldAddToSelection(indexPath: IndexPath, numSelections: Int) -> Bool {
        return true // indexPath.row != 2
    }
}

// MARK: - Characters limit

extension CameraViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // get the current text, or use an empty string if that failed
        let currentText = textView.text ?? ""
        
        // attempt to read the range they are trying to change, or exit if we can't
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        // add their new text to the existing text
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        
        // make sure the result is under __ characters
        return updatedText.count <= 500
    }
}
