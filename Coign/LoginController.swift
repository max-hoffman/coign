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

class LoginController: DataController, FBSDKLoginButtonDelegate {

    //MARK: - facebook login
    @IBOutlet weak var facebookLoginButton: FBSDKLoginButton!
    //var databaseManager: UserDataBaseManager?
    //var rootRef: FIRDatabaseReference?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        facebookLoginButton.delegate = self
        //rootRef = FIRDatabase.database().reference()
          }

//    func fetchProfile() {
//        
//        let connection = FBSDKGraphRequestConnection()
//        let parameters = ["fields":"email, name, id"]
//        let request = FBSDKGraphRequest.init(graphPath: "me", parameters: parameters)
//        connection.add(request, completionHandler: {
//            (connection, result, error) in
//            print("Facebook graph Result:", result)
//            //let dataDict = JSONSerialization.jsonObject(with: result!, options: JSONSerialization.ReadingOptions.mutableContainers)
//            print(JSONSerialization.isValidJSONObject(result!))
//            
//            let validJSONObject: Data?
//            
//            do{
//            validJSONObject = try JSONSerialization.data(withJSONObject: result!, options: JSONSerialization.WritingOptions.prettyPrinted)
//            
//                let dataDict = try JSONSerialization.jsonObject(with: validJSONObject!, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String: AnyObject]
//            
//                print(dataDict["name"])
//            }
//            catch{
//                print("json error")
//            }
//            
//        })
//        
//        connection.start()
//        
//        //TODO: assign graph vars to
//    }
    
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
            if self.rootRef != nil {
                //self.databaseManager = UserDataBaseManager()
                //check if user is new or not
                //UserDataBaseManager.sharedInstance.
                print("no error from login controller")
            }
        })
        
        //self.IsUserNew()
        let graphParameters = ["fields": "id, name"]
        let facebookDict = practiceFetchProfile(parameters: graphParameters)
        print(facebookDict)
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

