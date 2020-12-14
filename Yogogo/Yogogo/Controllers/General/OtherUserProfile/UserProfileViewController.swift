//
//  UserProfileViewController.swift
//  Yogogo
//
//  Created by prince on 2020/12/14.
//

import UIKit
import Firebase

class UserProfileViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var posts: [Post] = []
    
    let userManager = UserManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupCollectionView()
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
        collectionView.register(UserProfileTabsCollectionReusableView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: UserProfileTabsCollectionReusableView.identifier)
    }
    
    private func setupNavigation() {
//        navigationController?.navigationBar.barTintColor = .white
        navigationItem.backBarButtonItem?.tintColor = .label
        navigationItem.backButtonTitle = ""
        
        navigationItem.title = "yooonova"
    }
}

extension UserProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 0
        }
        return 30
//        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let model = posts[indexPath.item]
        
        guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: UserPostCollectionViewCell.identifier,
                for: indexPath) as? UserPostCollectionViewCell
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
                                                                         withReuseIdentifier: UserProfileTabsCollectionReusableView.identifier,
                                                                         for: indexPath) as? UserProfileTabsCollectionReusableView
            else { return UICollectionReusableView() }
            headerForTabs.delegate = self
            return headerForTabs
        }
        
        guard let headerForInfo = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                     withReuseIdentifier: UserProfileHeaderCollectionReusableView.identifier,
                                                                     for: indexPath) as? UserProfileHeaderCollectionReusableView
        else { return UICollectionReusableView() }
        
//        headerForInfo.setup()
        return headerForInfo
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {
            return CGSize(width: collectionView.width, height: 250)
        }
        // Size of section tabs
        return CGSize(width: collectionView.width, height: 50)
    }   
}

extension UserProfileViewController: UserProfileTabsCollectionReusableViewDelegate {
    
    func gridButtonDidTap() {
        // Reload collection view
    }
    
    func listButtonDidTap() {
        // Reload collection view
    }
}
