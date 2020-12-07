//
//  EditUsernameViewController.swift
//  Yogogo
//
//  Created by prince on 2020/12/7.
//

import UIKit

class EditUsernameViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField! {
        didSet {
            usernameTextField.text = text
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
        if let textInput = usernameTextField.text {
            tapHandler?(textInput)
            navigationController?.popViewController(animated: true)
        }
    }
}
