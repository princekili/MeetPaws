//
//  PostViewController.swift
//  Yogogo
//
//  Created by prince on 2020/12/2.
//

import UIKit

class MyPostViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var post: Post?
    
    var deleteHandler: (() -> Void)?
    
    // MARK: -
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        setupNavigationBar()
    }
    
    // MARK: -
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupNavigationBar() {
        navigationItem.backButtonTitle = ""
    }
}

extension MyPostViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PostTableViewCell.identifier, for: indexPath) as? PostTableViewCell else { return UITableViewCell() }
        
        guard let currentPost = post else { return UITableViewCell() }
        cell.setup(post: currentPost)
        cell.delegatePresentAlert = self
        cell.delegatePresentUser = self
        cell.delegateReloadView = self
        
        // Delete the post
        self.deleteHandler = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
            print("------ Delete the post: \(currentPost.postId) ------")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension MyPostViewController: PostTableViewCellPresentAlertDelegate {

    func presentAlert(postId: String) {
        
        // UIAlertController
        let moreActionsAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // UIAlertAction - Check the author
        guard let posts = UserManager.shared.currentUser?.posts else { return }
        
        var action: UIAlertAction
        
        if posts.contains(postId) {
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
                
                self?.confirmDeletePostAlert(postId: postId)
            }
            action = deleteAction
            
        } else {
            let hideAction = UIAlertAction(title: "Hide", style: .destructive) { [weak self] _ in
                
                self?.confirmHidePostAlert(postId: postId)
                
            }
            action = hideAction
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            moreActionsAlertController.dismiss(animated: true, completion: nil)
        }
        
        // addAction
        moreActionsAlertController.addAction(action)
        moreActionsAlertController.addAction(cancelAction)
        
        self.present(moreActionsAlertController, animated: true, completion: nil)
    }
    
    func confirmDeletePostAlert(postId: String) {
        
        // UIAlertController
        let confirmAlertController = UIAlertController(title: nil, message: "Delete Post?", preferredStyle: .alert)
        
        // UIAlertAction
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            
            PostManager.shared.deletePost(postId: postId) {
                // Delete the post on tableView
                self.deleteHandler?()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            confirmAlertController.dismiss(animated: true, completion: nil)
        }
        
        // addAction
        confirmAlertController.addAction(deleteAction)
        confirmAlertController.addAction(cancelAction)
        
        self.present(confirmAlertController, animated: true, completion: nil)
    }
    
    func confirmHidePostAlert(postId: String) {
        
        // UIAlertController
        let confirmAlertController = UIAlertController(title: nil, message: "Hide Post?", preferredStyle: .alert)
        
        // UIAlertAction
        let hideAction = UIAlertAction(title: "Hide", style: .destructive) { _ in
            
            PostManager.shared.hide(with: postId) {
                // Delete(Hide) the post on tableView
                self.deleteHandler?()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            confirmAlertController.dismiss(animated: true, completion: nil)
        }
        
        // addAction
        confirmAlertController.addAction(hideAction)
        confirmAlertController.addAction(cancelAction)
        
        self.present(confirmAlertController, animated: true, completion: nil)
    }
}

extension MyPostViewController: PostTableViewCellPresentUserDelegate {
    
    func presentUser() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension MyPostViewController: ButtonDidTapReloadDelegate {
    
    func reloadView(cell: UITableViewCell) {
        tableView.reloadData()
    }
}
