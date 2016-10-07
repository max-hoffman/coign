//
//  LoginControllerExtensions.swift
//  Coign
//
//  Created by Maximilian Hoffman on 10/6/16.
//  Copyright © 2016 Exlent Studios. All rights reserved.
//

import Foundation
import Firebase

extension LoginController {
    
    /**
     Check if the user is new or not
     */
    public func IsUserNew() {
        
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
                
                //check if the user node exists
                self.rootRef?.child("name").child(facebookID).observe(FIRDataEventType.value, with: {
                    [weak weakSelf = self]
                    snapshot in
                    if snapshot.value == nil { //user is new
                        print("user is new")
                    }
                    else { //user node already exists
                        print("user already exists")
                        
                        //make new user
                        weakSelf?.createNewUser(facebookID: facebookID, name: name, pictureURL: pictureURL)
                    }
                })
            }
            print("IsUserNew completion block ended")
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
