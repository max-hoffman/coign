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

class LoginController: UIViewController, FBSDKLoginButtonDelegate {

    //MARK: - facebook login
    @IBOutlet weak var facebookLoginButton: FBSDKLoginButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        facebookLoginButton.delegate = self
        
        if let token = FBSDKAccessToken.current(){
          fetchProfile()
        }
    }

    func fetchProfile() {
        let parameters = ["fields": "email, name, picture.type(large), id"]
        
        let nextrequest: FBSDKGraphRequest = FBSDKGraphRequest(graphPath:"me/friends", parameters: parameters, httpMethod: "GET")
        nextrequest.start { (connection, result, error) -> Void in
            guard let result = result as? [String:[AnyObject]], let listOfFriends = result["data"]  else {
                return
            }
        }
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
            print("User logged in with facebook")
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

