//
//  MessageLoadingIndicator.swift
//  Insdogram
//
//  Created by prince on 2020/12/20.
//

import UIKit

class MessageLoadingIndicator: UIActivityIndicatorView {

    var const: CGFloat!
    
    var chatVC: ChatViewController!
    
    var order: Bool!
    
    // MARK: -
    
    init(frame: CGRect, const: CGFloat, chatVC: ChatViewController) {
        super.init(frame: frame)
        self.const = const
        self.chatVC = chatVC
        setupIndicator()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: -
    
    private func setupIndicator() {
        hidesWhenStopped = true
        var topConst: CGFloat = 90
        if const == 8 {
            topConst = 70
        }
        color = .black
        chatVC.view.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            centerXAnchor.constraint(equalTo: chatVC.view.centerXAnchor),
            topAnchor.constraint(equalTo: chatVC.view.topAnchor, constant: topConst),
            widthAnchor.constraint(equalToConstant: 25),
            heightAnchor.constraint(equalToConstant: 25)
        ]
        NSLayoutConstraint.activate(constraints)
    }
}
