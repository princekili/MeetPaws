//
//  ProfileViewController.swift
//  Yogogo
//
//  Created by prince on 2020/12/2.
//

import UIKit
import Firebase

class MyProfileViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    let userManager = UserManager.shared
    
    var myPosts: [Post] = []
    
    var isLoadingPost = false
    
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupCollectionView()
        setupRefresher()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupNavigation()
        collectionView.reloadData()
    }
    
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self

        // Header for tabs
        // It's necessary for programming UI
        collectionView.register(MyProfileTabsCollectionReusableView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: MyProfileTabsCollectionReusableView.identifier)
    }
    
    private func setupNavigation() {
        navigationItem.backBarButtonItem?.tintColor = .label
        navigationItem.backButtonTitle = ""
        
        let title = userManager.currentUser?.username
        navigationItem.title = title
    }
    
    private func setupRefresher() {
        collectionView.refreshControl = refreshControl
        refreshControl.backgroundColor = UIColor.clear
        refreshControl.tintColor = UIColor.lightGray
        refreshControl.addTarget(self,
                                 action: #selector(loadMyRecentPosts),
                                 for: UIControl.Event.valueChanged
        )
    }
}

// MARK: - load My Recent Posts

extension MyProfileViewController {
    
    @objc private func loadMyRecentPosts() {
        guard let userId = UserManager.shared.currentUser?.userId else { return }
        userManager.getUserInfo(userId: userId) { (user) in
            
            var postIds = user.posts
            postIds = postIds.filter { $0 != "" }
            
            for postId in postIds {
                
                print("------ Loading My Recent Post: \(postId) ------")
                
                self.isLoadingPost = true
                
                PostManager.shared.getMyRecentPost(postId: postId, start: self.myPosts.first?.timestamp, limit: 18) { [weak self] (newPost) in
                    
                    // Add the array to the beginning of the posts arrays
                    self?.myPosts.append(newPost)
                    
                    self?.myPosts.sort(by: { $0.timestamp > $1.timestamp })
                    
                    // Save to local PostManager
                    guard let myPosts = self?.myPosts else { return }
                    PostManager.shared.postsOfCurrentUser = myPosts
                    
                    self?.isLoadingPost = false
                    
                    if ((self?.refreshControl.isRefreshing) != nil) == true {
                        
                        // Delay 0.5 second before ending the refreshing in order to make the animation look better
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: {
                            self?.refreshControl.endRefreshing()
                            self?.displayNewPost(newPost: newPost)
                        })
                        
                    } else {
                        self?.displayNewPost(newPost: newPost)
                    }
                }
            }
        }
    }
    
    private func displayNewPost(newPost post: Post) {
//        // Make sure we got some new posts to display
//        guard posts.count > 0 else {
//            return
//        }
//
//        // Display the posts by inserting them to the table view
//        var indexPaths: [IndexPath] = []
//
////        self.tableView.beginUpdates()
//
//        for num in 0...(posts.count - 1) {
//            let indexPath = IndexPath(item: num, section: 0)
//            indexPaths.append(indexPath)
//        }
//        self.collectionView.insertItems(at: indexPaths)
////        self.tableView.endUpdates()
    }
}

extension MyProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 0
        }
//        return 30
        return myPosts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = myPosts[indexPath.item]
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyPostCollectionViewCell.identifier,
                                                            for: indexPath) as? MyPostCollectionViewCell
        else {
            return UICollectionViewCell()
        }
        
        cell.setupForTest()
//        cell.setup(with: model)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = (view.width - 2)/3
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        // get the model and open the PostVC
//        let model = posts[indexPath.item]
//        let postVC = PostViewController(model: nil)
//        postVC.title = "Posts"
//        postVC.navigationItem.largeTitleDisplayMode = .never
//        navigationController?.pushViewController(postVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        // Header only
        guard kind == UICollectionView.elementKindSectionHeader else {
            // No footer
            return UICollectionReusableView()
        }
        
        if indexPath.section == 1 {
            // tabs header
            guard let headerForTabs = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                         withReuseIdentifier: MyProfileTabsCollectionReusableView.identifier,
                                                                         for: indexPath) as? MyProfileTabsCollectionReusableView
            else { return UICollectionReusableView() }
            headerForTabs.delegate = self
            return headerForTabs
        }
        
        guard let headerForInfo = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                     withReuseIdentifier: MyProfileHeaderCollectionReusableView.identifier,
                                                                     for: indexPath) as? MyProfileHeaderCollectionReusableView
        else { return UICollectionReusableView() }
        
        headerForInfo.setup()
        headerForInfo.delegate = self
        return headerForInfo
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {
            return CGSize(width: collectionView.width,
                          height: 250)
        }
        // Size of section tabs
        return CGSize(width: collectionView.width,
                      height: 50)
    }
}

// MARK: - MyProfileTabsCollectionReusableViewDelegate

extension MyProfileViewController: MyProfileTabsCollectionReusableViewDelegate {
    
    func gridButtonDidTap() {
        // Reload collection view
    }
    
    func listButtonDidTap() {
        // Reload collection view
    }
}

// MARK: - MyProfileHeaderCollectionReusableViewDelegate

extension MyProfileViewController: MyProfileHeaderCollectionReusableViewDelegate {
    
    func myProfileHeaderDidTapPostsButton(_ header: MyProfileHeaderCollectionReusableView) {
        // scroll to the posts
        let indexPath = IndexPath(row: 0, section: 1)
        collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
    }
}
