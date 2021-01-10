//
//  CommentsViewController.swift
//  Insdogram
//
//  Created by prince on 2020/12/25.
//

import UIKit
import Kingfisher
import Firebase

class CommentsViewController: UIViewController {

    var postComments: [Comment] = []
    
    var post: Post?
    
    var user: User? // for segue to UserProfile
    
    var deleteHandler: ((Int) -> Void)?
    
    let segueIdCommentsToUserProfile = "SegueCommentsToUserProfile"
    
    // MARK: - @IBOutlet
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var myProfileImage: UIImageView! {
        didSet {
            if let currentUser = UserManager.shared.currentUser {
                let url = URL(string: currentUser.profileImage)
                myProfileImage.kf.setImage(with: url)
            }
            myProfileImage.layer.cornerRadius = myProfileImage.frame.size.width / 2
            myProfileImage.layer.masksToBounds = true
            myProfileImage.translatesAutoresizingMaskIntoConstraints = false
            myProfileImage.contentMode = .scaleAspectFill
        }
    }
    
    @IBOutlet weak var messageTextView: UITextView! {
        didSet {
            messageTextView.text = nil
            messageTextView.textColor = .label
            messageTextView.textContainerInset = UIEdgeInsets(top: 5, left: 5, bottom: 0, right: 10)
            messageTextView.layer.borderWidth = 0.5
            messageTextView.layer.borderColor = UIColor.systemGray.cgColor
            messageTextView.layer.cornerRadius = 14
            messageTextView.layer.masksToBounds = true
            messageTextView.isScrollEnabled = false
            messageTextView.translatesAutoresizingMaskIntoConstraints = false
            messageTextView.delegate = self
        }
    }
    
    @IBOutlet weak var sendButton: UIButton! {
        didSet {
            let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
            let image = UIImage(systemName: "arrow.up", withConfiguration: config)
            sendButton.setImage(image, for: .normal)
            sendButton.backgroundColor = ThemeColors.selectedOutcomingColor
            sendButton.layer.cornerRadius = 15
            sendButton.layer.masksToBounds = true
            sendButton.tintColor = .white
            sendButton.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    // MARK: -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNavigationBar()
        setupMessageTextView()
        hideKeyboardWhenDidTapAround()
        loadComments()
        observePost()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
        if segue.identifier == segueIdCommentsToUserProfile {
            guard let userProfileVC = segue.destination as? UserProfileViewController else { return }
            // Pass user data to userProfileVC
            userProfileVC.user = self.user
        }
    }
    
    // MARK: - @IBAction
    
    @IBAction func sendButtonDidTap(_ sender: UIButton) {
        guard let content = messageTextView.text else { return }
        guard let post = self.post else { return }
        CommentManager.shared.uploadComment(post: post, content: content) { [weak self] in
            print("------ uploadComment: \(content) ------")
            self?.messageTextView.text = ""
            self?.setupMessageTextView()
        }
        self.view.endEditing(true)
    }
    
    // MARK: - Set up
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupNavigationBar() {
        navigationItem.backButtonTitle = ""
    }
    
    private func setupMessageTextView() {
        messageTextView.placeholder = "Add a comment..."
    }
    
    private func animateActionButton() {
        var buttonToAnimate = UIButton()
        if messageTextView.text.count >= 1 {
            if sendButton.alpha == 1 { return }
            sendButton.alpha = 1
            buttonToAnimate = sendButton
        } else if messageTextView.text.count == 0 {
            sendButton.alpha = 0
        }
        buttonToAnimate.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        UIView.animate(withDuration: 0.55, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
            buttonToAnimate.transform = .identity
        })
    }
    
    private func observePost() {
        guard let postId = self.post?.postId else { return }
        PostManager.shared.observeUserPost(postId: postId) { [weak self] (newPost) in
            self?.post = newPost
            self?.loadComments()
        }
    }
    
    // MARK: -
    
    private func loadComments() {
        
        guard let post = self.post else { return }
        var commentIds = post.comments
        commentIds = commentIds.filter { $0 != "" }
        
        var postComments: [Comment] = []
        
        for commentId in commentIds {
            
            // The commentId should not be in the ignoreList
            if let ignoreList = UserManager.shared.currentUser?.ignoreList {
                guard !ignoreList.contains(commentId) else { continue }
            }
            print("------ Loading Post Comment: \(commentId) ------")
            
            CommentManager.shared.getComments(commentId: commentId) { [weak self] (newComment) in
                
                postComments.append(newComment)
                postComments.sort(by: { $0.timestamp < $1.timestamp })
                
                // The userId should not be in the ignoreList
                if let ignoreList = UserManager.shared.currentUser?.ignoreList {
                    for blockedUserId in ignoreList {
                        postComments = postComments.filter { $0.userId != blockedUserId }
                    }
                }
                
                self?.postComments = postComments
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
        }
    }
}

extension CommentsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return postComments.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CommentsTableViewCell.identifier, for: indexPath) as? CommentsTableViewCell else { return UITableViewCell() }

        if indexPath.section == 0 {
            guard let currentPost = post else { return UITableViewCell() }
            cell.setupPost(with: currentPost)
            return cell
            
        } else {
            let currentComment = postComments[indexPath.row]
            cell.setupComment(with: currentComment, at: indexPath.row)
            cell.delegatePresent = self
            // Delete the comment
            self.deleteHandler = { [weak self] index in
                self?.postComments.remove(at: index)
                tableView.reloadData()
                print("------ Delete the comment: \(currentComment.commentId) ------")
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
}

extension CommentsViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // get the current text, or use an empty string if that failed
        let currentText = textView.text ?? ""
        
        // attempt to read the range they are trying to change, or exit if we can't
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        // add their new text to the existing text
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        
        // make sure the result is under __ characters
        return updatedText.count <= 50
    }
    
    func textViewDidChange(_ textView: UITextView) {
//        animateActionButton()
        
        // MARK: To change the height of messageTextView
        
//        let size = CGSize(width: textView.frame.width, height: 150)
//        let estSize = textView.sizeThatFits(size)
//        messageTV.constraints.forEach { (constraint) in
//            if constraint.firstAttribute != .height { return }
//            chatVC.messageHeightHandler(constraint, estSize)
//            chatVC.messageContainerHeightHandler(heightAnchr, estSize)
//        }
    }
}

extension CommentsViewController: CommentsTableViewCellDelegate {
    
    func presentUser(user: User, at index: Int) {
        // Get user data from cell
        self.user = user
        
        guard let myself = Auth.auth().currentUser?.uid else { return }
        if user.userId == myself {
            showMyProfileVC()
        
        } else {
            performSegue(withIdentifier: segueIdCommentsToUserProfile, sender: nil)
        }
    }
    
    func showMyProfileVC() {
        let storyboard = UIStoryboard(name: StoryboardName.main.rawValue, bundle: nil)
        let myProfileVC = storyboard.instantiateViewController(identifier: StoryboardId.myProfileVC.rawValue)
        
        self.navigationController?.pushViewController(myProfileVC, animated: true)
    }
    
    func presentAlert(with comment: Comment, at index: Int) {
        
        // UIAlertController
        let moreActionsAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // UIAlertAction - Check the author
        guard let userId = UserManager.shared.currentUser?.userId else { return }
        let commentId = comment.commentId
        
        if comment.userId == userId {
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
                self?.confirmDeleteCommentAlert(with: commentId)
            }
            moreActionsAlertController.addAction(deleteAction)
            
        } else {
            let hideAction = UIAlertAction(title: "Hide", style: .destructive) { [weak self] _ in
                
                self?.confirmHideCommentAlert(with: commentId, at: index)
                
            }
            moreActionsAlertController.addAction(hideAction)
            
            let reportAction = UIAlertAction(title: "Report", style: .destructive) { [weak self] _ in
                
                self?.confirmReportCommentAlert(with: commentId, at: index)
                
            }
            moreActionsAlertController.addAction(reportAction)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            moreActionsAlertController.dismiss(animated: true, completion: nil)
        }
        moreActionsAlertController.addAction(cancelAction)
        
        self.present(moreActionsAlertController, animated: true, completion: nil)
    }
    
    func confirmDeleteCommentAlert(with commentId: String) {
        
        // UIAlertController
        let confirmAlertController = UIAlertController(title: nil, message: "Delete Comment?", preferredStyle: .alert)
        
        // UIAlertAction
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            
            guard let post = self.post else { return }
            CommentManager.shared.deleteComment(of: post, commentId: commentId)
            WrapperProgressHUD.showSuccess()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            confirmAlertController.dismiss(animated: true, completion: nil)
        }
        
        // addAction
        confirmAlertController.addAction(deleteAction)
        confirmAlertController.addAction(cancelAction)
        
        self.present(confirmAlertController, animated: true, completion: nil)
    }
    
    func confirmHideCommentAlert(with commentId: String, at index: Int) {
        
        // UIAlertController
        let confirmAlertController = UIAlertController(title: nil, message: "Hide Post?", preferredStyle: .alert)
        
        // UIAlertAction
        let hideAction = UIAlertAction(title: "Hide", style: .destructive) { _ in
            
            PostManager.shared.hide(with: commentId) {
                // Delete(Hide) the post on tableView
                self.deleteHandler?(index)
                WrapperProgressHUD.showSuccess()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            confirmAlertController.dismiss(animated: true, completion: nil)
        }
        
        // addAction
        confirmAlertController.addAction(hideAction)
        confirmAlertController.addAction(cancelAction)
        
        self.present(confirmAlertController, animated: true, completion: nil)
    }
    
    func confirmReportCommentAlert(with commentId: String, at index: Int) {
        
        // UIAlertController
        let title = "Report Inappropriate Comment?"
        let message = "Your report is anonymous."
        let confirmAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // UIAlertAction
        let reportAction = UIAlertAction(title: "Report", style: .destructive) { _ in
            WrapperProgressHUD.showSuccess()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            confirmAlertController.dismiss(animated: true, completion: nil)
        }
        
        // addAction
        confirmAlertController.addAction(reportAction)
        confirmAlertController.addAction(cancelAction)
        
        self.present(confirmAlertController, animated: true, completion: nil)
    }
}
