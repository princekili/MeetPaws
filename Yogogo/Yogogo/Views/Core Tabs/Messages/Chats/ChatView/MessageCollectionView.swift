//
//  MessageCollectionView.swift
//  Insdogram
//
//  Created by prince on 2020/12/20.
//

import UIKit

class MessageCollectionView: UICollectionView, UIGestureRecognizerDelegate {

    var chatVC: ChatVC!
    
    var collectionViewOrigin: CGPoint!
    
    var isLongPress = false
    
    // MARK: -
    
    init(collectionViewLayout layout: UICollectionViewLayout, chatVC: ChatVC) {
        super.init(frame: .zero, collectionViewLayout: layout)
        self.chatVC = chatVC
        setupCollectionView()
        setupLongPress()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: -
    
//    func handleAddSubView() {
//        chatVC.view.addSubview(self)
//        translatesAutoresizingMaskIntoConstraints = false
//    }
    
    private func setupCollectionView() {
        chatVC.view.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false
        delegate = chatVC
        dataSource = chatVC
        backgroundColor = .clear
        contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 32, right: 0)
        register(ChatCell.self, forCellWithReuseIdentifier: "ChatCell")
        isUserInteractionEnabled = true
        let constraints = [
            topAnchor.constraint(equalTo: chatVC.view.topAnchor),
            bottomAnchor.constraint(equalTo: chatVC.messageContainer.topAnchor),
            leadingAnchor.constraint(equalTo: chatVC.view.leadingAnchor),
            trailingAnchor.constraint(equalTo: chatVC.view.trailingAnchor, constant: 120)
        ]
        NSLayoutConstraint.activate(constraints)
        collectionViewOrigin = frame.origin
        let panLeftGesture = UIPanGestureRecognizer(target: self, action: #selector(handleLeftGesture(gesture:)))
        addGestureRecognizer(panLeftGesture)
    }
    
    // MARK: -
    
    @objc private func handleLeftGesture(gesture: UIPanGestureRecognizer) {
        let gestureView = gesture.view!
        let translation = gesture.translation(in: chatVC.view)
        switch gesture.state {
        case .began, .changed:
            if translation.x < 400 && gestureView.center.x - translation.x > gestureView.center.x {
                gestureView.center = CGPoint(x: gestureView.center.x + translation.x, y: gestureView.center.y)
                gesture.setTranslation(CGPoint.zero, in: chatVC.view)
            }
        case .ended:
            UIView.animate(withDuration: 0.3) {
                self.frame.origin = self.collectionViewOrigin
            }
        default:
            break
        }
    }
    
    // MARK: -
    
    private func setupLongPress() {
        let gesture = UILongPressGestureRecognizer(target: chatVC, action: #selector(chatVC.handleLongPressGesture(longPress:)))
        gesture.delegate = self
        gesture.delaysTouchesBegan = true
        gesture.minimumPressDuration = 0.5
        addGestureRecognizer(gesture)
    }
    
    // MARK: -
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    // MARK: -

    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
