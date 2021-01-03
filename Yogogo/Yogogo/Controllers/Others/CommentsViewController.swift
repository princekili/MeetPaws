//
//  CommentsViewController.swift
//  Insdogram
//
//  Created by prince on 2020/12/25.
//

import UIKit

class CommentsViewController: UIViewController {

    var postComments: [Comment] = []
    
    var post: Post?
    
    // MARK: - @IBOutlet
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var myProfileImage: UIImageView! {
        didSet {
            myProfileImage.layer.cornerRadius = myProfileImage.frame.size.width / 2
            myProfileImage.layer.masksToBounds = true
            myProfileImage.translatesAutoresizingMaskIntoConstraints = false
            myProfileImage.contentMode = .scaleAspectFill
        }
    }
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var sendButton: UIButton!
    
    // MARK: -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNavigationBar()
        hideKeyboardWhenDidTapAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - Set up
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupNavigationBar() {
        navigationItem.backButtonTitle = ""
    }
    
    // MARK: -
    
    private func loadComments() {
        
        guard let post = self.post else { return }
        var commentIds = post.comments
        commentIds = commentIds.filter { $0 != "" }
        
        var postComments: [Comment] = []
        
        for commentId in commentIds {
            print("------ Loading Post Comment: \(commentId) ------")
            
            CommentManager.shared.observeComments(commentId: commentId) { [weak self] (newComment) in
                
                postComments.append(newComment)
                postComments.sort(by: { $0.timestamp < $1.timestamp })
                self?.postComments = postComments
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
        }
    }
}

extension CommentsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return postComments.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CommentsTableViewCell.identifier, for: indexPath) as? CommentsTableViewCell else { return UITableViewCell() }
        
        if indexPath.section == 0 {
            guard let currentPost = post else { return UITableViewCell() }
            cell.setupPost(with: currentPost)
            return cell
        } else {
            let currentComment = postComments[indexPath.row]
            cell.setupComment(with: currentComment)
            return cell
        }
    }
}
