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
    
    var user: User? // for segue to UserProfile
    
    var isLoadingPost = false
    
    let refreshControl = UIRefreshControl()
    
    var deleteHandler: ((Int) -> Void)?
    
    let segueIdFeedToUserProfile = "SegueFeedToUserProfile"
    
    let segueIdFeedToComment = "SegueFeedToComment"
    
    var postIndex: Int?
    
    // MARK: -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNavigationBar()
        setupRefresher()
        getCurrentUserInfo()
        SearchManager.shared.getUsers {}
        tabBarController?.delegate = self
    }
 
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadRecentPosts()
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
        if segue.identifier == "CameraVC" {
            guard let cameraVC = segue.destination as? CameraViewController else { return }
            cameraVC.delegate = self
            
        } else if segue.identifier == segueIdFeedToUserProfile {
            guard let userProfileVC = segue.destination as? UserProfileViewController else { return }
            // Pass user data to userProfileVC
            userProfileVC.user = self.user
            
        } else if segue.identifier == segueIdFeedToComment {
            guard let commentsVC = segue.destination as? CommentsViewController else { return }
            guard let index = postIndex else { return }
            commentsVC.post = postFeed[index]
        }
    }
    
    // MARK: - Set up
    
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
    
    // MARK: - getCurrentUserInfo
    
    private func getCurrentUserInfo() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        UserManager.shared.getCurrentUserInfo(userId: userId) { (user) in
            
            let myUser = user
            print("------  Get the currentUser info successfully in FeedVC ------")
            print(myUser)
        }
    }
}

// MARK: -

extension FeedViewController: PassPostIndexDelegate {
    
    func passPostIndex(with index: Int) {
        postIndex = index
        performSegue(withIdentifier: segueIdFeedToComment, sender: nil)
    }
}

// MARK: - Managing Post Download and Display

extension FeedViewController: LoadRecentPostsDelegate {
    
    // For CameraVC
    func loadRecentPost() {
        loadRecentPosts()
    }
    
    @objc func loadRecentPosts() {

        print("------ Loading Recent Posts... ------")
        
        isLoadingPost = true
        
        PostManager.shared.getRecentPosts(start: postFeed.first?.timestamp, limit: 10) { [weak self] (newPosts) in
            
            if newPosts.count > 0 {
                // Add the array to the beginning of the posts arrays
                self?.postFeed.insert(contentsOf: newPosts, at: 0)
                self?.postFeed.removeDuplicates()
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
        cell.delegatePassPostIndex = self
        
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
        
        PostManager.shared.getOldPosts(start: lastPostTimestamp, limit: 10) { [weak self] (oldPosts) in
            
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
        
        if posts.contains(postId) {
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
                self?.confirmDeletePostAlert(postId: postId, at: index)
            }
            moreActionsAlertController.addAction(deleteAction)
            
        } else {
            let hideAction = UIAlertAction(title: "Hide", style: .destructive) { [weak self] _ in
                self?.confirmHidePostAlert(postId: postId, at: index)
            }
            moreActionsAlertController.addAction(hideAction)
            
            let reportAction = UIAlertAction(title: "Report", style: .destructive) { [weak self] _ in
                self?.confirmReportPostAlert(postId: postId, at: index)
            }
            moreActionsAlertController.addAction(reportAction)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            moreActionsAlertController.dismiss(animated: true, completion: nil)
        }
        moreActionsAlertController.addAction(cancelAction)
        
        self.present(moreActionsAlertController, animated: true, completion: nil)
    }
    
    func confirmDeletePostAlert(postId: String, at index: Int) {
        
        // UIAlertController
        let confirmAlertController = UIAlertController(title: nil, message: "Delete Post?", preferredStyle: .alert)
        
        // UIAlertAction
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            
            PostManager.shared.deletePost(postId: postId) {
                // Delete the post on tableView
                self.deleteHandler?(index)
                self.tableView.reloadData()
                WrapperProgressHUD.showSuccess()
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
    
    func confirmHidePostAlert(postId: String, at index: Int) {
        
        // UIAlertController
        let confirmAlertController = UIAlertController(title: nil, message: "Hide Post?", preferredStyle: .alert)
        
        // UIAlertAction
        let deleteAction = UIAlertAction(title: "Hide", style: .destructive) { _ in
            
            PostManager.shared.hide(with: postId) {
                // Delete(Hide) the post on tableView
                self.deleteHandler?(index)
                self.tableView.reloadData()
                WrapperProgressHUD.showSuccess()
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
    
    func confirmReportPostAlert(postId: String, at index: Int) {
        
        // UIAlertController
        let title = "Report Inappropriate Post?"
        let message = "Your report is anonymous."
        let confirmAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // UIAlertAction
        let reportAction = UIAlertAction(title: "Report", style: .destructive) { _ in
            WrapperProgressHUD.showSuccess()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            confirmAlertController.dismiss(animated: true, completion: nil)
        }
        
        // addAction
        confirmAlertController.addAction(reportAction)
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
            performSegue(withIdentifier: segueIdFeedToUserProfile, sender: nil)
        }
    }
    
    func showMyProfileVC() {
        let storyboard = UIStoryboard(name: StoryboardName.main.rawValue, bundle: nil)
        let myProfileVC = storyboard.instantiateViewController(identifier: StoryboardId.myProfileVC.rawValue)
        
        self.navigationController?.pushViewController(myProfileVC, animated: true)
    }
}

extension FeedViewController: ButtonDidTapReloadDelegate {
    
    func reloadView(cell: UITableViewCell) {
        tableView.reloadData()
    }
}

// MARK: - Tap tab bar item to scroll to the top of FeedVC.

extension FeedViewController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let tabBarIndex = tabBarController.selectedIndex
        if tabBarIndex == 0 {
            let indexPath = IndexPath(row: 0, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
}
