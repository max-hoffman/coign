//
//  ViewController.swift
//  Coign
//
//  Created by Maximilian Hoffman on 9/3/16.
//  Copyright © 2016 The Maxes. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FBSDKLoginKit
import FBSDKCoreKit

class LoginController: UIViewController, FBSDKLoginButtonDelegate {

    //MARK: - facebook login
    @IBOutlet weak var facebookLoginButton: FBSDKLoginButton!
    var dict : NSDictionary?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        facebookLoginButton.delegate = self
          }

    func fetchProfile() {
        
        //TODO: make graph request
        //let parameters = ["fields": "email"]
        let connection = FBSDKGraphRequestConnection()
        let parameters = ["fields":"email, name, id"]
        let request = FBSDKGraphRequest.init(graphPath: "me", parameters: parameters)
        connection.add(request, completionHandler: {
            (connection, result, error) in
            print("Facebook graph Result:", result)
            
            
        })
        
        connection.start()
        
        //TODO: assign graph vars to
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            print(error!.localizedDescription)
            return
        }
            
        let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            
            //successful login
            print("User logged in with facebook")
            self.fetchProfile()
            })
        
        let storyboard = UIStoryboard(name: "MainApp", bundle: nil)
        let controller  = storyboard.instantiateInitialViewController()!
        self.present(controller, animated: true, completion: nil)
    }

    func loginButtonWillLogin(_ loginButton: FBSDKLoginButton!) -> Bool {
        return true
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        try! FIRAuth.auth()?.signOut()
        print("User logged out")
    }
}

