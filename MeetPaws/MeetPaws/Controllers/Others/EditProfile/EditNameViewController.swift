//
//  EditNameViewController.swift
//  MeetPaws
//
//  Created by prince on 2020/12/6.
//

import UIKit

class EditNameViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField! {
        didSet {
            nameTextField.text = text
            nameTextField.delegate = self
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
        if let textInput = nameTextField.text {
            tapHandler?(textInput)
            navigationController?.popViewController(animated: true)
        }
    }
}

extension EditNameViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // get the current text, or use an empty string if that failed
        let currentText = textField.text ?? ""

        // attempt to read the range they are trying to change, or exit if we can't
        guard let stringRange = Range(range, in: currentText) else { return false }

        // add their new text to the existing text
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)

        // make sure the result is under __ characters
        return updatedText.count <= 30
    }
}
