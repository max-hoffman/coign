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


//MARK: - Login flow extensions
private extension LoginController {
    
    /**
     Checks if the user is new or not; this is the bulk of the login work. The fetches from BF/FIR are asynchronous so the logic has to be nested. For some reason the FIR observation fires several times, so there's a guard to prevent the entire function from repeatedly being called.
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
                print(error!.localizedDescription)
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
                UserDefaults.standard.set(facebookID, forKey: FirTree.UserParameter.Id.rawValue)
                UserDefaults.standard.set(name, forKey: FirTree.UserParameter.Name.rawValue)
                UserDefaults.standard.set(pictureURL, forKey: FirTree.UserParameter.Picture.rawValue)
                
                FirTree.rootRef.child(FirTree.Node.Users.rawValue).child(facebookID).observeSingleEvent(of: .value, with: {
                    snapshot in
                    
                    //prevent repetitive auto-queries from FIR database
                    if UserDefaults.standard.object(forKey: "most recent login date") != nil {
                        print("firebase observation self-activated")
                        return
                    }
                    
                    if snapshot.exists()  { //user node exists
                        
                        //update last login time
                        let loginTime = Date().shortDate
                        FirTree.rootRef
                            .child(FirTree.Node.Users.rawValue)
                            .child(facebookID)
                            .updateChildValues([FirTree.UserParameter.MostRecentLoginDate.rawValue: loginTime])
                        UserDefaults.standard.set(
                            loginTime,
                            forKey: FirTree.UserParameter.MostRecentLoginDate.rawValue)
                    }
                    else { //user is new
                        
                        //make new user
                        weakSelf?.createNewUser(facebookID: facebookID, name: name, pictureURL: pictureURL)
                    }
                    
                    //set home menu as root VC
                    let mainStoryBoard = UIStoryboard(name: "MainApp", bundle: nil)
                    let revealViewController = mainStoryBoard.instantiateViewController(withIdentifier: "RevealVC")
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.window?.rootViewController = revealViewController
                    
                })
                //check if user is new || cache existing user settings
//                FirTree.rootRef.child(FirTree.Node.Users.rawValue).child(facebookID).observe(FIRDataEventType.value, with: {
//                
//                    snapshot in
//                    
//                    //prevent repetitive auto-queries from FIR database
//                    if UserDefaults.standard.object(forKey: "most recent login date") != nil {
//                        print("firebase observation self-activated")
//                        return
//                    }
//                    
//                    if snapshot.exists()  { //user node exists
//                        
//                        //update last login time
//                        let loginTime = Date().shortDate
//                        FirTree.rootRef
//                            .child(FirTree.Node.Users.rawValue)
//                            .child(facebookID)
//                            .updateChildValues([FirTree.UserParameter.MostRecentLoginDate.rawValue: loginTime])
//                        UserDefaults.standard.set(
//                            loginTime,
//                            forKey: FirTree.UserParameter.MostRecentLoginDate.rawValue)
//                    }
//                    else { //user is new
//                      
//                        //make new user
//                        weakSelf?.createNewUser(facebookID: facebookID, name: name, pictureURL: pictureURL)
//                    }
//                    
//                    //set home menu as root VC
//                    let mainStoryBoard = UIStoryboard(name: "MainApp", bundle: nil)
//                    let revealViewController = mainStoryBoard.instantiateViewController(withIdentifier: "RevealVC")
//                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
//                    appDelegate.window?.rootViewController = revealViewController
//                })
            }
        })
        connection.start()
    }
    
    /**
     Adds a node to the "users" branch of the FIR tree - indexed by the user's facebook ID. This is an unused overloaded class; feel like it could be useful, because it is all of the logic to make a facebook query and then store that data in the FIR tree.
     */
//    func createNewUser() -> Void {
//        
//        //return dictionary
//        var jsonData: [String: Any]?
//        
//        //formal request parameters and callback
//        let request = FBSDKGraphRequest.init(
//            graphPath: "me",
//            parameters: ["fields": "id, name, picture.type(large)"])
//        let connection = FBSDKGraphRequestConnection()
//        connection.add(request, completionHandler: {
//            [weak weakSelf = self]
//            (connection, result, error) in
//            
//            if error != nil {
//                print(error?.localizedDescription ?? error!)
//                return
//            }
//            
//            jsonData = weakSelf?.parseJSON(validJSONObject: result)
//            
//            if let facebookID = jsonData?["id"] as! String?,
//                let name = jsonData?["name"] as! String?,
//                let picture = jsonData?["picture"] as! [String: AnyObject]?,
//                let data = picture["data"] as! [String: AnyObject]?,
//                let pictureURL = data["url"] as! String? {
//                
//            weakSelf?.createNewUser(facebookID: facebookID, name: name, pictureURL: pictureURL)
//            }
//        })
//        connection.start()
//    }
    
    //MARK: - updated, haven't verified
    /**
     Overloaded new user creation; used to create new user in "users" branch of FIR tree during loginControlFlow().
     */
    func createNewUser(facebookID: String, name: String, pictureURL: String) {
        let post: [String : Any] = [FirTree.UserParameter.Name.rawValue : name,
                                    FirTree.UserParameter.Picture.rawValue : pictureURL,
                                    FirTree.UserParameter.MostRecentLoginDate.rawValue: FirTree.UserParameter.NewUser.rawValue]
        FirTree.rootRef.child(FirTree.Node.Users.rawValue).child(facebookID).setValue(post)
        UserDefaults.standard.set(FirTree.UserParameter.NewUser.rawValue, forKey: FirTree.UserParameter.MostRecentLoginDate.rawValue)
    }
}

