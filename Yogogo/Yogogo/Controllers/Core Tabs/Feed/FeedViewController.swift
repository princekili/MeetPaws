//
//  FeedViewController.swift
//  Yogogo
//
//  Created by prince on 2020/11/30.
//

import UIKit
import FirebaseAuth

class FeedViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        setupNavigation()
        
        getPostsInfo()
    }
 
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        handleNotAuthenticated()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupNavigation() {
//        navigationController?.navigationBar.barTintColor = .white
        navigationItem.backBarButtonItem?.tintColor = .label
        navigationItem.backButtonTitle = ""
    }
    
    fileprivate func handleNotAuthenticated() {
        // Check auth status
        if Auth.auth().currentUser == nil {
            // Show sign in
            let loginVC = SignInViewController()
            loginVC.modalPresentationStyle = .fullScreen
            present(loginVC, animated: false)
        }
    }
    
    func getPostsInfo() {
        PostManager.shared.getRecentPosts(limit: 3) { (newPosts) in
            newPosts.forEach { (post) in
                print("-------")
                print("Post ID: \(post.postId)")
                print("userId: \(post.userId)")
                print("username: \(post.username)")
                print("Image URL: \(post.imageFileURL)")
                print("userDidLike: \(post.userDidLike)")
                print("caption: \(post.caption)")
                print("Timestamp: \(post.timestamp)")
            }
        }
    }
}

extension FeedViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 5 }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FeedTableViewCell.identifier, for: indexPath) as? FeedTableViewCell else { return UITableViewCell() }
        
        return cell
    }
}
