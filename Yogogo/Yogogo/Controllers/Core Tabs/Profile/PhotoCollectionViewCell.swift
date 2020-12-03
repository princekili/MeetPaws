//
//  PhotoCollectionViewCell.swift
//  Yogogo
//
//  Created by prince on 2020/12/2.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "PhotoCollectionViewCell"

    @IBOutlet weak var photoImageView: UIImageView!
    
    func setup(test imageName: String) {
        photoImageView.image = UIImage(systemName: "")
    }
}
