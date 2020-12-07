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
            bioTextView.placeholder = "Fill in your bio..."
            bioTextView.text = text
            bioTextView.layer.borderWidth = 0.5
            bioTextView.layer.borderColor = UIColor.lightGray.cgColor
            bioTextView.layer.cornerRadius = 4
            bioTextView.layer.masksToBounds = true
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
