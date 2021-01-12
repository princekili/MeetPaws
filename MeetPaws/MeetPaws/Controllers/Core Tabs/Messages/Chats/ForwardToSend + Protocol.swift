//
//  ForwardToSend + Protocol.swift
//  MeetPaws
//
//  Created by prince on 2020/12/21.
//

import Foundation

protocol ForwardToFriend {
    
    func forwardToSelectedFriend(user: User, for name: String)
    
}

// MARK: -

extension ChatViewController: ForwardToFriend {
    
    // MARK: -
    
    func forwardToSelectedFriend(user: User, for name: String) {
        responseButtonPressed(userResponse.messageToForward!, forwardedName: name)
        self.user = user
        messages = []
        collectionView.reloadData()
        setupChat()
    }
}
