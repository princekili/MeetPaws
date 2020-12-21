//
//  SharedMediaVC.swift
//  Insdogram
//
//  Created by prince on 2020/12/20.
//

import UIKit
import Firebase
import Kingfisher

class SharedMediaVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    var user: User!
    
    var sharedMedia = [Messages]()
    
    var collectionView: UICollectionView!
    
    let emptyLabel = UILabel()
    
    // MARK: -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Shared Media"
        setupCollectionView()
        setupEmptyView()
        getSharedMedia()
    }
    
    // MARK: -
    
    private func getSharedMedia(){
        guard let currentUser = UserManager.shared.currentUser else { return }
        
        let id = user.userId
        Database.database().reference().child("messages").child(currentUser.userId).child(id).observe(.childAdded) { (snap) in
            guard let values = snap.value as? [String: Any] else { return }
            let sharedMedia = Messages()
            sharedMedia.mediaUrl = values["mediaUrl"] as? String
            sharedMedia.videoUrl = values["videoUrl"] as? String
            sharedMedia.sender = values["sender"] as? String
            sharedMedia.time = values["time"] as? NSNumber
            guard sharedMedia.mediaUrl != nil else { return }
            self.sharedMedia.insert(sharedMedia, at: 0)
            if self.sharedMedia.count == 0 { self.emptyLabel.isHidden = false }
            self.collectionView.reloadData()
        }
    }
    
    // MARK: -
    
    private func setupEmptyView() {
        view.addSubview(emptyLabel)
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.textColor = .gray
        emptyLabel.font = UIFont.boldSystemFont(ofSize: 24)
        emptyLabel.text = "EMPTY"
        emptyLabel.isHidden = true
        let constraints = [
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: -
    
    private func setupCollectionView(){
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 4
        let size = view.bounds.width/3 - 3
        layout.itemSize =  CGSize(width: size, height: size)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.addSubview(collectionView)
        collectionView.autoresizesSubviews = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        collectionView.register(SharedMediaCell.self, forCellWithReuseIdentifier: "sharedMediaCell")
        let constraints = [
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: -
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sharedMedia.count
    }
    
    // MARK: -
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "sharedMediaCell", for: indexPath) as? SharedMediaCell else { return UICollectionViewCell() }
        let message = sharedMedia[indexPath.row]
        cell.message = message
        
        let url = URL(string: message.mediaUrl)
        cell.imageView.kf.setImage(with: url)
        
        cell.playButton.isHidden = message.videoUrl == nil
        cell.sharedMediaVC = self
        return cell
    }
    
    // MARK: -
    
    func zoomImageHandler(_ image: UIImageView, _ message: Messages){
        let _ = SelectedImageView(image, message, nil, self)
    }
}
