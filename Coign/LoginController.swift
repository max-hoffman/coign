//
//  LoginController.swift
//  Coign
//
//  Created by Maximilian Hoffman on 9/3/16.
//  Copyright © 2016 Exlent Studios. All rights reserved.
//
                                                                                                                                                                              
import UIKit
import Firebase
import FirebaseAuth
import FBSDKLoginKit
import FBSDKCoreKit

class LoginController: UIViewController, FBSDKLoginButtonDelegate {
    
    //MARK: - properties
    @IBOutlet weak var facebookLoginButton: FBSDKLoginButton!
    
    //MARK: - facebook delegate functions
    
    /**
     Logs user into app. Brings to a web view (looks ugly but I'm not sure if there's a way around it), where user enters FB data and logs in. Initiates the login flow to check if user is new, and proceeds accordingly.
    */
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        //if there's an error, cancel login
        if error != nil {
            print(error!.localizedDescription)
            return
        }
        
        //issue user a FB credential, auto signs them in the the FIR "user"
        let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        print(credential)
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in

            //quit if FB request error
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            
            //log the user in
            self.loginControlFlow()
        })
    }
    
    func loginButtonWillLogin(_ loginButton: FBSDKLoginButton!) -> Bool {
        return true
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        try! FIRAuth.auth()?.signOut()
        print("User had error and was stuck on login page")
    }
    
    //MARK: - superclass functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        facebookLoginButton.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
