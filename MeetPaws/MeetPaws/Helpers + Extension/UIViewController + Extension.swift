//
//  UIViewController + Extension.swift
//  Yogogo
//
//  Created by prince on 2020/11/30.
//

import UIKit
import Lottie

extension UIViewController {
    
    // MARK: - hide Keyboard
    
    func hideKeyboardWhenDidTapAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - SHOWS ALERT VIEW WHEN THERE'S AN ERROR
    
    func showAlert(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - BLANK VIEW FOR CONTROLLERS WITH NO DATA.
    
    func setupBlankView(_ blankLoadingView: AnimationView) {
        view.addSubview(blankLoadingView)
        blankLoadingView.translatesAutoresizingMaskIntoConstraints = false
        blankLoadingView.backgroundColor = .white
        blankLoadingView.play()
        blankLoadingView.loopMode = .loop
        blankLoadingView.backgroundBehavior = .pauseAndRestore
        let constraints = [
            blankLoadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blankLoadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blankLoadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            blankLoadingView.topAnchor.constraint(equalTo: view.topAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: - GRADIENT BACKGROUND
    
    func setupGradientLayer() -> CAGradientLayer {
        let gradient = CAGradientLayer()
        let topColor = UIColor(red: 100/255, green: 90/255, blue: 255/255, alpha: 1).cgColor
        let bottomColor = UIColor(red: 140/255, green: 135/255, blue: 255/255, alpha: 1).cgColor
        gradient.colors = [topColor, bottomColor]
        gradient.locations = [0, 1]
        return gradient
    }
    
    // MARK: -
    
//    func setLeftAlignedNavigationItemTitle(text: String,
//                                           color: UIColor,
//                                           margin left: CGFloat) {
//        let titleLabel = UILabel()
//        titleLabel.textColor = color
//        titleLabel.text = text
//        titleLabel.textAlignment = .left
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//
//        self.navigationItem.titleView = titleLabel
//
//        guard let containerView = self.navigationItem.titleView?.superview else { return }
//
//        // NOTE: This always seems to be 0. Huh??
//        let leftBarItemWidth = self.navigationItem.leftBarButtonItems?.reduce(0, { $0 + $1.width })
//
//        NSLayoutConstraint.activate([
//            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
//            titleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
//            titleLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor,
//                                             constant: (leftBarItemWidth ?? 0) + left),
//            titleLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor)
//        ])
//    }
    
}
