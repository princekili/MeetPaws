//
//  UIImageView + Extension.swift
//  Yogogo
//
//  Created by prince on 2020/11/29.
//

// MARK: Load images from Firebase Storage and caches them.

import UIKit

private let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
    
    private var activityIndicator: UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .black
        addSubview(activityIndicator)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        
        return activityIndicator
    }
    
    // MARK: -
    
//    func loadImage(url: String) {
//        self.image = nil
//
//        if let image = imageCache.object(forKey: url as NSString) {
//            self.image = image
//            return
//        }
//        isUserInteractionEnabled = false
//        backgroundColor = .lightGray
//
//        let indicator = activityIndicator
//        DispatchQueue.main.async {
//            indicator.startAnimating()
//        }
//
//        let imageUrl = URL(string: url)
//        if imageUrl == nil { return }
//
//        let task = URLSession.shared.dataTask(with: imageUrl!) { (data, response, error) in
//            guard let data = data else { return }
//
//            DispatchQueue.main.async {
//                guard let image = UIImage(data: data) else {
//                    print(error!.localizedDescription)
//                    return
//                }
//                self.backgroundColor = .clear
//                self.isUserInteractionEnabled = true
//                indicator.stopAnimating()
//                self.alpha = 1
//                imageCache.setObject(image, forKey: url as NSString)
//                self.image = image
//            }
//        }
//        task.resume()
//    }
}
