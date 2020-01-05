//
//  MainViewController.swift
//  DATC
//
//  Created by Valentina Vențel on 14/11/2019.
//  Copyright © 2019 Valentina Vențel. All rights reserved.
//

import Foundation
import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import FacebookLogin
import FacebookCore
import Firebase
import GoogleSignIn
import FirebaseAuth
import FirebaseAuth

class MainViewConroller: UIViewController {
    
    func loginManagerDidComplete(_ result: LoginResult) {

        switch result {
        case .cancelled:
            let alertController = UIAlertController(
                title: "Login Cancelled",
                message: "User cancelled login.",
                preferredStyle: .alert
            )
            self.present(alertController, animated: true, completion: nil)

        case .failed(let error):
           let alertController = UIAlertController(
                title: "Login Fail",
                message: "Login failed with error \(error)",
                preferredStyle: .alert
            )
           self.present(alertController, animated: true, completion: nil)

        case .success( _, _, _):
            self.performSegue(withIdentifier: "loginSegue", sender: nil)
        }

    }
    
    @IBAction private func loginButton() {
        let loginManager = LoginManager()
    
        loginManager.logIn(
            permissions: [.publicProfile, .userFriends],
            viewController: self
        ) { result in
            self.loginManagerDidComplete(result)
        }
    }
    
    func signIn(_ signIn: GIDSignIn!,
        presentViewController viewController: UIViewController!) {
      self.present(viewController, animated: true, completion: nil)
        
    }
    
    func signIn(_ signIn: GIDSignIn!,
        dismissViewController viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func googleLoginButton(_ sender: Any) {
        //GIDSignIn.sharedInstance()?.delegate = self as? GIDSignInDelegate
        //GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    // Client ID: 483907564434-btsrqjeruduk8434c1f6hvqvvq05ir4q.apps.googleusercontent.com
    override func viewDidLoad() {
        super.viewDidLoad()
        //TODO: remove this
//        self.performSegue(withIdentifier: "loginSegue", sender: nil)

        
        GIDSignIn.sharedInstance().presentingViewController = self
        //GIDSignIn.sharedInstance()?.restorePreviousSignIn()
        if ((GIDSignIn.sharedInstance()?.currentUser) != nil) {
            self.performSegue(withIdentifier: "loginSegue", sender: nil)
        }
    }
    
}

