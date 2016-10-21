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
private extension LoginController {
    
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
                
                //store data in UserDefaults for later use
                UserDefaults.standard.set(facebookID, forKey: "facebookID")
                UserDefaults.standard.set(name, forKey: "name")
                UserDefaults.standard.set(pictureURL, forKey: "pictureURL")
                
                //check if user is new || cache existing user settings
                weakSelf?.rootRef?.child("users").child(facebookID).observe(FIRDataEventType.value, with: {
                    
                    snapshot in
                    
                    //set home menu as root VC
                    let mainStoryBoard = UIStoryboard(name: "MainApp", bundle: nil)
                    let revealViewController = mainStoryBoard.instantiateViewController(withIdentifier: "RevealVC")
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.window?.rootViewController = revealViewController
                    
                    if snapshot.exists()  { //user node exists
                        
                        //update last login time
                        let loginTime = Date().shortDate
                        self.rootRef?.child("users").child(facebookID).updateChildValues(["most recent login date": loginTime])
                        UserDefaults.standard.set(loginTime, forKey: "most recent login date")
                    }
                    else { //user is new
                      
                        //make new user
                        weakSelf?.createNewUser(facebookID: facebookID, name: name, pictureURL: pictureURL)
                    }
                })
            }
            })
        connection.start()
    }
    
    /**
     Add a node to the users branch of the FIR tree - marked by the user's facebook ID. Not used anywhere, could be useful in the future.
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
                
            weakSelf?.createNewUser(facebookID: facebookID, name: name, pictureURL: pictureURL)
            }
            })
        
        connection.start()
    }
    
    /**
     Overloaded new user creation: to be called inside of FBSDK completion block where params are already available
     */
    func createNewUser(facebookID: String, name: String, pictureURL: String) {
        let post: [String : Any] = ["name" : name,
                                    "picture" : pictureURL,
                                    "most recent login date": "new user"]
        self.rootRef?.child("users").child(facebookID).setValue(post)
        UserDefaults.standard.set("new user", forKey: "most recent login date")
    }
}

