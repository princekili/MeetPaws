//
//  SearchViewController.swift
//  Yogogo
//
//  Created by prince on 2020/11/30.
//

import UIKit

class SearchViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var searchController: UISearchController!
    
    var sortedUsers: [User] = []
    
    var searchResults: [User] = []
    
    var selectedUser: User?
    
    let segueId = "SegueSearchToUserProfile"
    
    // MARK: -
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        setupSearchBar()
        navigationItem.backButtonTitle = ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getUsers()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueId {
            guard let userProfileVC = segue.destination as? UserProfileViewController else { return }
            userProfileVC.user = selectedUser
        }
    }
    
    // MARK: -
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupSearchBar() {
        searchController = UISearchController(searchResultsController: nil)
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchBar.placeholder = "Search usernames..."
    }
    
    private func filterContent(for searchText: String) {
        searchResults = sortedUsers.filter({ (user) -> Bool in
            let isMatch = user.username.localizedCaseInsensitiveContains(searchText) || user.fullName.localizedCaseInsensitiveContains(searchText)
            return isMatch
        })
    }
    
    private func getUsers() {
        // Get all userIds
        SearchManager.shared.getUserIds { (userIds) in
            for userId in userIds {
                SearchManager.shared.getUserInfo(of: userId)
            }
        }
        sortedUsers = SearchManager.shared.users.sorted { $0.username < $1.username }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    private func showMyProfileVC() {
        let storyboard = UIStoryboard(name: StoryboardName.main.rawValue, bundle: nil)
        let myProfileVC = storyboard.instantiateViewController(identifier: StoryboardId.myProfileVC.rawValue)
        navigationController?.pushViewController(myProfileVC, animated: true)
    }
}

// MARK: -

extension SearchViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filterContent(for: searchText)
            tableView.reloadData()
        }
    }
}

// MARK: -

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchTableViewCell.identifier, for: indexPath) as? SearchTableViewCell
        else { return UITableViewCell() }
        
        let result = searchController.isActive ? searchResults[indexPath.row] : sortedUsers[indexPath.row]
        cell.setup(with: result)
        
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
