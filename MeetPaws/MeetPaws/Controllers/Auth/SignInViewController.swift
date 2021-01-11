//
//  LoginViewController.swift
//  Yogogo
//
//  Created by prince on 2020/12/2.
//

import UIKit
import AuthenticationServices
import FirebaseAuth

class SignInViewController: UIViewController {
    
    static let shared = SignInViewController()
    
    let userManager = UserManager.shared
    
    @IBOutlet weak var signInWithAppleButton: UIButton! {
        didSet {
            signInWithAppleButton.layer.cornerRadius = 8
            signInWithAppleButton.layer.masksToBounds = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: - Show next view
    // MARK: First time sign in?
    
    func showNextVC() {
        userManager.checkFirstTimeSignIn { [weak self] (isFirstTime) in
            if isFirstTime == true {
                print("------ isFirstTime = true ------")
                self?.showPickUsernameVC()
            } else {
                print("------ isFirstTime = false ------")
                self?.showMainView()
            }
        }
    }
    
    func showPickUsernameVC() {
        let storyboard = UIStoryboard(name: StoryboardName.auth.rawValue, bundle: nil)
        let nextController = storyboard.instantiateViewController(withIdentifier: StoryboardId.pickUsernameVC.rawValue)
        nextController.modalPresentationStyle = .fullScreen
        present(nextController, animated: true, completion: nil)
    }
    
    func showMainView() {
        let storyboard = UIStoryboard(name: StoryboardName.main.rawValue, bundle: nil)
        let nextController = storyboard.instantiateViewController(withIdentifier: StoryboardId.tabBarController.rawValue)
        nextController.modalPresentationStyle = .fullScreen
        present(nextController, animated: true, completion: nil)
        
        SceneDelegate().window?.rootViewController = nextController
    }
    
    // MARK: - Handle sign in
    
    @IBAction func signInWithAppleButtonDidTap(_ sender: CustomButton) {
        performSignIn()
    }
    
    private func performSignIn() {
        let request = createAppleIDRequest()
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    private func createAppleIDRequest() -> ASAuthorizationAppleIDRequest {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let nonce = randomNonceString()
        request.nonce = sha256(nonce)
        currentNonce = nonce
        return request
    }
    
    // MARK: - Default 'Sign in with Apple' button
    
//    private func setupSignInButton() {
//        let button = ASAuthorizationAppleIDButton()
//        button.addTarget(self, action: #selector(handleSignInWithAppleButtonDidTap), for: .touchUpInside)
//        button.center = view.center
//        view.addSubview(button)
//    }
//
//    @objc private func handleSignInWithAppleButtonDidTap() {
//        performSignIn()
//    }
}

// MARK: - ASAuthorizationControllerDelegate

@available(iOS 13.0, *)
extension SignInViewController: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            
            // Initialize a Firebase credential.
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString,
                                                      rawNonce: nonce)
            // Sign in with Firebase.
            Auth.auth().signIn(with: credential) { (authResult, error) in
                
                if error != nil {
                    // Error. If error.code == .MissingOrInvalidNonce, make sure
                    // you're sending the SHA256-hashed nonce as a hex string with
                    // your request to Apple.
                    print("Sign In Error: ", error!.localizedDescription)
                    let alertController = UIAlertController(title: "Sign In Error",
                                                            message: error!.localizedDescription,
                                                            preferredStyle: .alert)
                    
                    let okayAction = UIAlertAction(title: "OK",
                                                   style: .cancel,
                                                   handler: nil)
                    
                    alertController.addAction(okayAction)
                    self.present(alertController, animated: true, completion: nil)
                    
                    return
                }
                
                // MARK: - User is signed in to Firebase with Apple successfully.
                
                if let user = authResult?.user,
                   let fullName = appleIDCredential.fullName {
                    
                    let givenName = fullName.givenName
                    let familyName = fullName.familyName
                    let displayName = "\(givenName ?? "") \(familyName ?? "")"
                    
                    self.userManager.fullName = displayName
                    
                    print("Your're signed in as: \(displayName), id: \(user.uid), email: \(user.email ?? "unknown email").")
                    
                }
                // Show next view
                self.showNextVC()
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        print("Sign in with Apple errored: \(error)")
    }
}

// MARK: -

extension SignInViewController: ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

// MARK: -

// Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
private func randomNonceString(length: Int = 32) -> String {
    precondition(length > 0)
    let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
    var result = ""
    var remainingLength = length
    
    while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
            var random: UInt8 = 0
            let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
            if errorCode != errSecSuccess {
                fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
            }
            return random
        }
        
        randoms.forEach { random in
            if remainingLength == 0 {
                return
            }
            
            if random < charset.count {
                result.append(charset[Int(random)])
                remainingLength -= 1
            }
        }
    }
    return result
}

// MARK: -

import CryptoKit

// Unhashed nonce.
private var currentNonce: String?

// @available(iOS 13, *)
// func startSignInWithAppleFlow() {
//  let nonce = randomNonceString()
//  currentNonce = nonce
//  let appleIDProvider = ASAuthorizationAppleIDProvider()
//  let request = appleIDProvider.createRequest()
//  request.requestedScopes = [.fullName, .email]
//  request.nonce = sha256(nonce)
//
//  let authorizationController = ASAuthorizationController(authorizationRequests: [request])
//  authorizationController.delegate = self
//  authorizationController.presentationContextProvider = self
//  authorizationController.performRequests()
// }

@available(iOS 13, *)
private func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashedData = SHA256.hash(data: inputData)
    let hashString = hashedData.compactMap {
        return String(format: "%02x", $0)
    }.joined()
    
    return hashString
}
