//
//  EditNameViewController.swift
//  Yogogo
//
//  Created by prince on 2020/12/6.
//

import UIKit

class EditNameViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    
    var text: String?
    
    var index: Int?
    
    var tapHandler: ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func backButtonDidTap(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func donButtonDidTap(_ sender: UIBarButtonItem) {
        if let textInput = nameTextField.text {
            tapHandler?(textInput)
            navigationController?.popViewController(animated: true)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
