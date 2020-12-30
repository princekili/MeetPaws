//
//  FollowersViewController.swift
//  Insdogram
//
//  Created by prince on 2020/12/29.
//

import UIKit

class FollowersViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet var buttons: [UIButton]! {
        didSet {
            // Set up buttons' title
            guard let listOwner = listOwner else { return }
            let followersCount = listOwner.followers.count - 1
            buttons[0].setTitle("\(followersCount) Followers", for: .normal)
            let followingCount = listOwner.following.count - 1
            buttons[1].setTitle("\(followingCount) Following", for: .normal)
            
            // Add tags
            for (index, button) in buttons.enumerated() {
                button.tag = index
            }
        }
    }
    
    @IBOutlet weak var shortLineView: UIView!
    
    var searchController: UISearchController!
    
    var sortedUsers: [User] = []
    
    var searchResults: [User] = []
    
    var listOwner: User?
    
    var selectedUser: User?
    
    var followType: FollowType = .followers
    
    let segueId = "SegueFollowersToUserProfile"
    
    // MARK: -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupSearchBar()
        setupNavigationBar()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setupLineView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameFromFollowersOrFollowing()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
        if segue.identifier == segueId {
            guard let userProfileVC = segue.destination as? UserProfileViewController else { return }
            // Pass user data to userProfileVC
            userProfileVC.user = self.selectedUser
        }
    }
    
    // MARK: - Set up line view
    
    private func setupLineView() {
        var selectedButton: UIButton
        
        switch followType {
        case .followers:
            selectedButton = buttons[0]
        case .following:
            selectedButton = buttons[1]
        }
    
        shortLineView.frame.origin.x = selectedButton.frame.origin.x
    }
    
    private func setupNavigationBar() {
        navigationItem.backButtonTitle = ""
        guard let listOwner = listOwner else { return }
        navigationItem.title = listOwner.username
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        let customView = UIView()
        customView.backgroundColor = .systemBackground
        tableView.backgroundView = customView
    }
    
    private func setupSearchBar() {
        searchController = UISearchController(searchResultsController: nil)
        navigationItem.searchController = searchController
//        tableView.tableHeaderView = searchController.searchBar
        navigationItem.hidesSearchBarWhenScrolling = false
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.searchBarStyle = .default
        searchController.searchBar.placeholder = "Search the username..."
    }
    
    // MARK: -
    
    private func filterContent(for searchText: String) {
        searchResults = sortedUsers.filter({ (user) -> Bool in
            let isMatch = user.username.localizedCaseInsensitiveContains(searchText) || user.fullName.localizedCaseInsensitiveContains(searchText)
            return isMatch
        })
    }
    
    private func showMyProfileVC() {
        let storyboard = UIStoryboard(name: StoryboardName.main.rawValue, bundle: nil)
        let myProfileVC = storyboard.instantiateViewController(identifier: StoryboardId.myProfileVC.rawValue)
        navigationController?.pushViewController(myProfileVC, animated: true)
    }
    
    // MARK: - Switch the button
    
    private func animateLineView(_ sender: UIButton) {
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0) {
            self.shortLineView.frame.origin.x = sender.frame.origin.x
        }
    }
    
    private func isSelected(_ selectedButton: UIButton) {
        for button in buttons {
            if button == selectedButton {
                button.isSelected = true
            } else {
                button.isSelected = false
            }
        }
    }
    
    private func switchType(_ sender: UIButton) {
        guard sender.tag != followType.rawValue else { return }

        switch sender.tag {
        case 0:
            self.followType = .followers
        case 1:
            self.followType = .following
        default: break
        }
        
        // Get followers & following
        cameFromFollowersOrFollowing()
    }
    
    @IBAction func followTypeButtonsDidTap(_ sender: UIButton) {
        animateLineView(sender)
        isSelected(sender)
        switchType(sender)
        tableView.reloadData()
    }
    
    // MARK: - Get followers & following
    
    private func cameFromFollowersOrFollowing() {
        if followType == .followers {
            isSelected(buttons[0])
            getFollowers()
        } else {
            isSelected(buttons[1])
            getFollowing()
        }
    }
    
    private func getFollowers() {
        guard var followers = listOwner?.followers else { return }
        followers = followers.filter { $0 != "" }
        FollowManager.shared.users = []
        
        FollowManager.shared.getUsers(userIds: followers) { [weak self] in
            
            self?.sortedUsers = FollowManager.shared.users.sorted { $0.username < $1.username }
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    private func getFollowing() {
        guard var following = listOwner?.following else { return }
        following = following.filter { $0 != "" }
        FollowManager.shared.users = []
        
        FollowManager.shared.getUsers(userIds: following) { [weak self] in
            
            self?.sortedUsers = FollowManager.shared.users.sorted { $0.username < $1.username }
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
}

// MARK: -

extension FollowersViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filterContent(for: searchText)
            tableView.reloadData()
        }
    }
}

extension FollowersViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive {
            return searchResults.count
        } else {
            return sortedUsers.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FollowersTableViewCell.identifier, for: indexPath) as? FollowersTableViewCell
        else { return UITableViewCell() }
        
        let result = searchController.isActive ? searchResults[indexPath.row] : sortedUsers[indexPath.row]
        
        guard let currentUser = UserManager.shared.currentUser else { return UITableViewCell() }
        
        if listOwner?.userId == currentUser.userId {
            cell.setupForCurrentUser(with: result, type: followType)
        } else {
            cell.setupForOtherUsers(with: result)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.view.endEditing(true)
        
        selectedUser = searchController.isActive ? searchResults[indexPath.row] : sortedUsers[indexPath.row]
        
        if selectedUser?.userId == UserManager.shared.currentUser?.userId {
            showMyProfileVC()
        } else {
            performSegue(withIdentifier: segueId, sender: nil)
        }
    }
}
