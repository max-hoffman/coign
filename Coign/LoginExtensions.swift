//
//  LoginExtensions.swift
//  Coign
//
//  Created by Maximilian Hoffman on 10/29/16.
//  Copyright © 2016 Exlent Studios. All rights reserved.
//

import Foundation

extension LoginController {
    
    //MARK: - Login function
    
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
                
                //check if user is new || cache existing user settings
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
                        weakSelf?.createNewUser(facebookID: facebookID, name: name, pictureURL: pictureURL)
                    }
                    
                    //set home menu as root VC
                    let mainStoryBoard = UIStoryboard(name: Storyboard.MainApp.rawValue, bundle: .main)
                    let revealViewController = mainStoryBoard.instantiateViewController(withIdentifier: "RevealVC")
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.window?.rootViewController = revealViewController
                })
            }
        })
        connection.start()
    }
    
    //MARK: - New user function
    /**
     Adds a node to the "users" branch of the FIR tree - indexed by the user's facebook ID; used to create new user in "users" branch of FIR tree during loginControlFlow().
     */
    func createNewUser(facebookID: String, name: String, pictureURL: String) {
        
        //prep data
        let post: [String : Any] = [FirTree.UserParameter.Name.rawValue : name,
                                    FirTree.UserParameter.Picture.rawValue : pictureURL,
                                    FirTree.UserParameter.MostRecentLoginDate.rawValue: FirTree.UserParameter.NewUser.rawValue]
        
        //add date to new node
        FirTree.updateUser(withNewSettings: post)
        
        //update user defaults
        UserDefaults.standard.set(FirTree.UserParameter.NewUser.rawValue, forKey: FirTree.UserParameter.MostRecentLoginDate.rawValue)
    }
    
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

