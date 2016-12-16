//
//  LoginExtensions.swift
//  Coign
//
//  Created by Maximilian Hoffman on 10/29/16.
//  Copyright © 2016 Exlent Studios. All rights reserved.
//

import Foundation
import FirebaseAuth

extension LoginController {
    
    //MARK: - Login function
    
    /**
     Checks if the user is new or not; this is the bulk of the login work. The fetches from FB/FIR are asynchronous so the logic has to be nested
     //TODO: - make a loginFBSDKGraphRequest() func with completion handler that returns dictionary
     */
    func loginControlFlow() {
        
        //properties for calling and storing facebook fetch
        var jsonData: [String: Any]?
        let connection = FBSDKGraphRequestConnection()
        let request = FBSDKGraphRequest.init(graphPath: "me", parameters: ["fields": "id, name, picture.type(large), friends"])
        
        //initiate facebook fetch
        connection.add(request, completionHandler: {
            [weak weakSelf = self]
            (connection, result, error) in
            
            //facebook fetch failed, exit flow
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            
            //parse the json result
            jsonData = weakSelf?.parseJSON(result)
            
            //check for expected fetch data before proceeding
            if let facebookID = jsonData?["id"] as! String?,
                let name = jsonData?["name"] as! String?,
                let picture = jsonData?["picture"] as! [String: AnyObject]?,
                let pictureData = picture["data"] as! [String: AnyObject]?,
                let pictureURL = pictureData["url"] as! String?,
                let userID = FIRAuth.auth()?.currentUser?.uid,
                let friends = jsonData?["friends"] as? [String: AnyObject]?,
                let friendsArray = friends?["data"] as? [[String:AnyObject]]? {
                
                //start firbase fetch, see if the logged in user has signed up
                FirTree.rootRef.child(FirTree.Node.Users.rawValue).child(userID).observeSingleEvent(of: .value, with: {
                    snapshot in
                    
                    if snapshot.exists()  { //user node exists
                        
                        //extract FirTree data to update user defaults
                        /*fixes bug: user data does not load into settings after logout */
                        weakSelf?.existingUserLoggedIn(userID,
                                                       firTreeDictionary: snapshot.value as! Dictionary<String, Any>)
                    }
                    else { //user is new
                        FirTree.createNewUserInFirebase(userID,
                                                        facebookID: facebookID,
                                                        name: name,
                                                        pictureURL: pictureURL)
                    }
                    
                    //need the userID to be loaded into defaults first
                    if friendsArray != nil {
                        FirTree.updateUserFriends(friendsArray!)
                    }
                    
                    weakSelf?.setHomeMenuAsRootViewController()
                })
            }
            else {
                return
            }
        })
        connection.start()
    }
    
    
    fileprivate func setHomeMenuAsRootViewController() {
        //set home menu as root VC
        let mainStoryBoard = UIStoryboard(name: Storyboard.MainApp.rawValue, bundle: .main)
        let revealViewController = mainStoryBoard.instantiateViewController(withIdentifier: "RevealVC")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = revealViewController
    }
    
    
    fileprivate func existingUserLoggedIn(_ userID: String, firTreeDictionary value: Dictionary<String, Any>) {
        //extract FirTree data to update user defaults
        /*fixes bug: user data does not load into settings after logout */
        
        UserDefaults.standard.set(value[FirTree.UserParameter.Birthday.rawValue], forKey: FirTree.UserParameter.Birthday.rawValue)
        UserDefaults.standard.set(value[FirTree.UserParameter.Email.rawValue], forKey: FirTree.UserParameter.Email .rawValue)
        UserDefaults.standard.set(value[FirTree.UserParameter.Phone.rawValue], forKey: FirTree.UserParameter.Phone .rawValue)
        UserDefaults.standard.set(value[FirTree.UserParameter.Charity.rawValue], forKey: FirTree.UserParameter.Charity.rawValue)
        UserDefaults.standard.set(userID, forKey: FirTree.UserParameter.UserUID.rawValue)
        UserDefaults.standard.set(value[FirTree.UserParameter.FacebookUID.rawValue], forKey: FirTree.UserParameter.FacebookUID.rawValue)
        UserDefaults.standard.set(value[FirTree.UserParameter.Name.rawValue], forKey: FirTree.UserParameter.Name.rawValue)
        UserDefaults.standard.set(value[FirTree.UserParameter.Picture.rawValue], forKey: FirTree.UserParameter.Picture.rawValue)
        
        //update last login time
        let loginTime = Date().shortDate
        FirTree.rootRef
            .child(FirTree.Node.Users.rawValue)
            .child(userID)
            .updateChildValues([FirTree.UserParameter.MostRecentLoginDate.rawValue: loginTime])
        UserDefaults.standard.set(
            loginTime,
            forKey: FirTree.UserParameter.MostRecentLoginDate.rawValue)
    }
    
    //MARK: - New user function
    /**
     Adds a node to the "users" branch of the FIR tree - indexed by the user's facebook ID; used to create new user in "users" branch of FIR tree during loginControlFlow().
     */
//    func createNewUser(userID: String, facebookID: String, name: String, pictureURL: String) {
//        
//        //prep data
//        //TODO: make the "new user" node unnecessary by calling the 
//        let post: [String : Any] = [FirTree.UserParameter.Name.rawValue : name,
//                                    FirTree.UserParameter.Picture.rawValue : pictureURL,
//                                    FirTree.UserParameter.OutgoingCoigns.rawValue: 0,
//                                    FirTree.UserParameter.IncomingCoigns.rawValue: 0,
//                                    FirTree.UserParameter.FacebookUID.rawValue: facebookID,
//                                    FirTree.UserParameter.MostRecentLoginDate.rawValue: FirTree.UserParameter.NewUser.rawValue]
//        
//        //add date to new node
//        FirTree.updateUser(withNewSettings: post)
//        
//        //update user defaults
//        //TODO: change this so that we don't need the "new user" intermediary
//        UserDefaults.standard.set(FirTree.UserParameter.NewUser.rawValue, forKey: FirTree.UserParameter.MostRecentLoginDate.rawValue)
//        //store data in UserDefaults for later use
//        UserDefaults.standard.set(facebookID, forKey: FirTree.UserParameter.FacebookUID.rawValue)
//        UserDefaults.standard.set(name, forKey: FirTree.UserParameter.Name.rawValue)
//        UserDefaults.standard.set(pictureURL, forKey: FirTree.UserParameter.Picture.rawValue)
//        UserDefaults.standard.set(userID, forKey: FirTree.UserParameter.UserUID.rawValue)
//    }
    
    /**
     Overloaded new user creation - indexed by the user's facebook ID. This is an unused overloaded class; feel like it could be useful, because it is all of the logic to make a facebook query and then store that data in the FIR tree.
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
}

