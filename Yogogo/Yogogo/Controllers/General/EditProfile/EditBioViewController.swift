//
//  EditBioViewController.swift
//  Yogogo
//
//  Created by prince on 2020/12/7.
//

import UIKit

class EditBioViewController: UIViewController {
    
    @IBOutlet weak var bioTextView: UITextView! {
        didSet {
            bioTextView.placeholder = "Edit your bio..."
            bioTextView.text = text
            bioTextView.layer.borderWidth = 0.5
            bioTextView.layer.borderColor = UIColor.lightGray.cgColor
            bioTextView.layer.cornerRadius = 4
            bioTextView.layer.masksToBounds = true
            
            bioTextView.delegate = self
        }
    }
    
    var text: String?
    
    var tapHandler: ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func backButtonDidTap(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func doneButtonDidTap(_ sender: UIBarButtonItem) {
        if let textInput = bioTextView.text {
            tapHandler?(textInput)
            navigationController?.popViewController(animated: true)
        }
    }
}

extension EditBioViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // get the current text, or use an empty string if that failed
        let currentText = textView.text ?? ""
        
        // attempt to read the range they are trying to change, or exit if we can't
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        // add their new text to the existing text
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        
        // make sure the result is under __ characters
        return updatedText.count <= 100
    }
}
