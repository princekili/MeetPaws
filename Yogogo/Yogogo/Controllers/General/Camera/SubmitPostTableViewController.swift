//
//  SubmitPostTableViewController.swift
//  Yogogo
//
//  Created by prince on 2020/12/6.
//

import UIKit

class SubmitPostTableViewController: UITableViewController {

    var selectedImageView: UIImageView?
    
    @IBOutlet weak var imageButton: UIButton! {
        didSet {
            imageButton.setImage(selectedImageView?.image, for: .normal)
        }
    }
    
    @IBOutlet weak var captionTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    @IBAction func shareButtonDidTap(_ sender: UIBarButtonItem) {
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
}
