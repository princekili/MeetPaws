//
//  FeedViewController.swift
//  Yogogo
//
//  Created by prince on 2020/11/30.
//

import UIKit
import Firebase

class FeedViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var postFeed: [Post] = []
    
    var user: User?
    
    var isLoadingPost = false
    
    let refreshControl = UIRefreshControl()
    
    var deleteHandler: ((Int) -> Void)?
    
    // MARK: -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupNavigationBar()
        setupRefresher()
    }
 
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tableView.reloadData()
        loadRecentPosts()
        getCurrentUserInfo()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
        if segue.identifier == "CameraVC" {
            guard let cameraVC = segue.destination as? CameraViewController else { return }
            cameraVC.delegate = self
            
        } else if segue.identifier == "SegueUserProfile" {
            guard let userProfileVC = segue.destination as? UserProfileViewController else { return }
            // Pass user data to userProfileVC
            userProfileVC.user = self.user
        }
    }
    
    // MARK: -
    
    private func getCurrentUserInfo() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        UserManager.shared.getUserInfo(userId: userId) { (user) in
            
            let myUser = user
            print("------  Get the currentUser info successfully in FeedVC ------")
            print(myUser)
        }
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupNavigationBar() {
        navigationItem.backButtonTitle = ""
    }
    
    private func setupRefresher() {
        tableView.refreshControl = refreshControl
        refreshControl.backgroundColor = UIColor.clear
        refreshControl.tintColor = UIColor.lightGray
        refreshControl.addTarget(self,
                                 action: #selector(loadRecentPosts),
                                 for: UIControl.Event.valueChanged
        )
    }
}

// MARK: - Managing Post Download and Display

extension FeedViewController: LoadRecentPostsDelegate {
    
    func loadRecentPost() {
        loadRecentPosts()
    }
    
    @objc func loadRecentPosts() {
        
        print("------ Loading Recent Posts... ------")
        
        isLoadingPost = true
        
        PostManager.shared.getRecentPosts(start: postFeed.first?.timestamp, limit: 5) { [weak self] (newPosts) in
            
            if newPosts.count > 0 {
                // Add the array to the beginning of the posts arrays
                self?.postFeed.insert(contentsOf: newPosts, at: 0)
            }
            
            self?.isLoadingPost = false
            
            if ((self?.refreshControl.isRefreshing) != nil) == true {
                
                // Delay 0.5 second before ending the refreshing in order to make the animation look better
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: {
                    self?.refreshControl.endRefreshing()
                    self?.displayNewPosts(newPosts: newPosts)
                })
                
            } else {
                self?.displayNewPosts(newPosts: newPosts)
            }
        }
    }

    private func displayNewPosts(newPosts posts: [Post]) {
        
        // Make sure we got some new posts to display
        guard posts.count > 0 else {
            return
        }
        
        // Display the posts by inserting them to the table view
        var indexPaths: [IndexPath] = []
        
        self.tableView.beginUpdates()
        
        for num in 0...(posts.count - 1) {
            let indexPath = IndexPath(row: num, section: 0)
            indexPaths.append(indexPath)
        }
        self.tableView.insertRows(at: indexPaths, with: .fade)
        self.tableView.endUpdates()
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension FeedViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postFeed.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FeedTableViewCell.identifier, for: indexPath) as? FeedTableViewCell else { return UITableViewCell() }
        
        let currentPost = postFeed[indexPath.row]
        cell.setup(post: currentPost, at: indexPath.row)
        cell.delegatePresentAlert = self
        cell.delegatePresentUser = self
        cell.delegateReloadView = self
        
        // Delete the post on tableView
        self.deleteHandler = { [weak self] index in
            self?.postFeed.remove(at: index)
            tableView.reloadData()
            print("------ Delete the post: \(currentPost.postId) ------")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        // We want to trigger the loading when the user reaches the last two rows
        guard !isLoadingPost, postFeed.count - indexPath.row == 2 else {
            return
        }
        
        isLoadingPost = true
        
        guard let lastPostTimestamp = postFeed.last?.timestamp else {
            isLoadingPost = false
            return
        }
        
        print("------ Loading Old Posts... ------")
        
        PostManager.shared.getOldPosts(start: lastPostTimestamp, limit: 5) { [weak self] (oldPosts) in
            
            // Add old posts to existing arrays and table view
            var indexPaths: [IndexPath] = []
            
            self?.tableView.beginUpdates()
            
            for oldPost in oldPosts {
                self?.postFeed.append(oldPost)
                guard let count = self?.postFeed.count else { return }
                let indexPath = IndexPath(row: count - 1, section: 0)
                indexPaths.append(indexPath)
            }
            self?.tableView.insertRows(at: indexPaths, with: .fade)
            self?.tableView.endUpdates()
            
            self?.isLoadingPost = false
        }
    }
}

// MARK: - Present Alert

extension FeedViewController: FeedTableViewCellPresentAlertDelegate {

    func presentAlert(postId: String, at index: Int) {
        
        // UIAlertController
        let moreActionsAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // UIAlertAction - Check the author
        guard let posts = UserManager.shared.currentUser?.posts else { return }
        
        var action: UIAlertAction
        
        if posts.contains(postId) {
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
                
                self?.confirmAlert(postId: postId, at: index)
            }
            action = deleteAction
            
        } else {
            let reportAction = UIAlertAction(title: "Report", style: .destructive) { _ in
                
                // To report
            }
            action = reportAction
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            moreActionsAlertController.dismiss(animated: true, completion: nil)
        }
        
        // addAction
        moreActionsAlertController.addAction(action)
        moreActionsAlertController.addAction(cancelAction)
        
        self.present(moreActionsAlertController, animated: true, completion: nil)
    }
    
    func confirmAlert(postId: String, at index: Int) {
        
        // UIAlertController
        let confirmAlertController = UIAlertController(title: nil, message: "Delete Post?", preferredStyle: .alert)
        
        // UIAlertAction
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            
            PostManager.shared.deletePost(postId: postId) {
                // Delete the post on tableView
                self.deleteHandler?(index)
                self.tableView.reloadData()
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
}

extension FeedViewController: FeedTableViewCellPresentUserDelegate {
    
    func presentUser(user: User, at index: Int) {
        
        // Get user data from cell
        self.user = user
        
        guard let myself = Auth.auth().currentUser?.uid else { return }
        
        if user.userId == myself {
            showMyProfileVC()
        
        } else {
            performSegue(withIdentifier: "SegueUserProfile", sender: nil)
        }
    }
    
    func showMyProfileVC() {
        let storyboard = UIStoryboard(name: StoryboardName.main.rawValue, bundle: nil)
        let myProfileVC = storyboard.instantiateViewController(identifier: StoryboardId.myProfileVC.rawValue)
        
        self.navigationController?.pushViewController(myProfileVC, animated: true)
    }
}

extension FeedViewController: LikeButtonDidTapDelegate {
    
    func reloadView(cell: UITableViewCell) {
        tableView.reloadData()
    }
}
