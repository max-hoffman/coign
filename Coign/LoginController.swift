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
    
    //MARK: - properties
    @IBOutlet weak var facebookLoginButton: FBSDKLoginButton!
    var rootRef: FIRDatabaseReference?
    
    //MARK: - facebook delegate functions
    
    /**
     Logs user into app. Brings to a web view (looks ugly but I'm not sure if there's a way around it), where user enters FB data and logs in. Initiates the login flow to check if user is new, and proceeds accordingly. The login flow is nested because the servers return requests unpredictably, and it's not possible to serialize this thread. I.e. the fetches are asynchronous on concurrent threads, and the only way to make sure they happen in the correct order is to nest steps inside proceeding request completion blocks.
    */
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        //if there's an error, cancel login
        if error != nil {
            print(error!.localizedDescription)
            return
        }
        
        //issue user a FB credential, auto signs them in the the FIR "user"
        let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            
            //sign in with the
            if self.rootRef != nil {
                
                //nest login lg
                self.loginControlFlow()
            }
            else {
                print("no database connection; exiting app")
                return
            }
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
        rootRef = FIRDatabase.database().reference()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


//MARK: - Login flow extensions
extension LoginController {
    
    /**
     Check if the user is new or not
     */
    func loginControlFlow() {
        
        //properties for calling and storing facebook fetch
        var jsonData: [String: Any]?
        let connection = FBSDKGraphRequestConnection()
        let request = FBSDKGraphRequest.init(graphPath: "me", parameters: ["fields": "id, name, picture.type(large)"])
        
        //initiate facebook fetch
        connection.add(request, completionHandler: {
            [weak weakSelf = self]
            (connection, result, error) in
            
            //erroneous facebook fetch, close function short
            if error != nil {
                print(error?.localizedDescription)
                return
            }
            
            //parse the json result
            jsonData = weakSelf?.parseJSON(validJSONObject: result)
            
            //check for expected fetch data before proceeding
            if let facebookID = jsonData?["id"] as! String?,
                let name = jsonData?["name"] as! String?,
                let picture = jsonData?["picture"] as! [String: AnyObject]?,
                let data = picture["data"] as! [String: AnyObject]?,
                let pictureURL = data["url"] as! String? {
                
                //check if user is new || cache existing user settings
                weakSelf?.rootRef?.child("name").child(facebookID).observe(FIRDataEventType.value, with: {
                    
                    snapshot in
                    
                    if snapshot.value == nil { // then the user is new
                        
                        //make new user
                        weakSelf?.createNewUser(facebookID: facebookID, name: name, pictureURL: pictureURL)
                        
                        //send user to settings page
                        let storyboard = UIStoryboard(name: "MainMenu", bundle: nil)
                        let mainMenuController  = storyboard.instantiateInitialViewController()!
                        weakSelf?.present(mainMenuController, animated: true, completion: nil)
                        
                        let popoverController = storyboard.instantiateViewController(withIdentifier: "User Setup Controller")
                        mainMenuController.present(popoverController, animated: true, completion: nil)
                        
                    }
                    else { //user node already exists
                        print("user already exists")
                        
                        //send user to home page
                        let storyboard = UIStoryboard(name: "MainMenu", bundle: nil)
                        let mainMenuNC  = storyboard.instantiateInitialViewController()!
                        let mainMenuController = mainMenuNC.contentViewController as! MainMenuController
                        weakSelf?.present(mainMenuNC, animated: true, completion: nil)
                        
                        //weakSelf?.newUserLoginDelegate?.presentUserSetupPopover()
                        mainMenuController.presentUserSetupPopover()
                        
                        //let popoverController = storyboard.instantiateViewController(withIdentifier: "UserSetup") as! UIPopoverPresentationController
                        //mainMenuController.present(popoverController, animated: true, completion: nil)
                        
                    }
                })
            }
            })
        connection.start()
    }
    
    /**
     Add a node to the users branch of the FIR tree - marked by the user's facebook ID
     */
    func createNewUser() -> Void {
        
        var jsonData: [String: Any]?
        
        let connection = FBSDKGraphRequestConnection()
        let request = FBSDKGraphRequest.init(graphPath: "me", parameters: ["fields": "id, name, picture.type(large)"])
        
        connection.add(request, completionHandler: {
            [weak weakSelf = self]
            (connection, result, error) in
            
            if error != nil {
                print(error?.localizedDescription)
                return
            }
            
            jsonData = weakSelf?.parseJSON(validJSONObject: result)
            
            
            if let facebookID = jsonData?["id"] as! String?,
                let name = jsonData?["name"] as! String?,
                let picture = jsonData?["picture"] as! [String: AnyObject]?,
                let data = picture["data"] as! [String: AnyObject]?,
                let pictureURL = data["url"] as! String? {
                
                let post: [String : Any] = ["name" : name,
                                            "picture" : pictureURL]
                weakSelf?.rootRef?.child("users").child(facebookID).setValue(post)
                print("attempted to create new user node")
            }
            })
        
        connection.start()
    }
    
    /**
     Overloaded new user creation: to be called inside of FBSDK completion block where params are already available
     */
    func createNewUser(facebookID: String, name: String, pictureURL: String) {
        let post: [String : Any] = ["name" : name,
                                    "picture" : pictureURL]
        self.rootRef?.child("users").child(facebookID).setValue(post)
        print("attempted to create new user node")
        
    }
}

