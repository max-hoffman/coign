//
//  UserDatabaseManager.swift
//  Coign
//
//  Created by Maximilian Hoffman on 10/2/16.
//  Copyright © 2016 Exlent Studios. All rights reserved.
//

import Foundation

class UserDataBaseManager {
    
    //MARK: - properties
    var name: String?
    var email: String?
    var friendsList: [Int]?
    var preferredCharity: String?
    var profilePictureURL: String?
    var facebookID: Int?
    //var firebaseID: String?
    
    //MARK: init
    required init() {
        fetchProfile()
    }
    
    //MARK: - class funcitons
    //fetch data from facebook, assign to local vars
    func fetchProfile() {
        
        //request parameters
        let connection = FBSDKGraphRequestConnection()
        let parameters = ["fields":"email, name, id, picture.type(large), friends"]
        let request = FBSDKGraphRequest.init(graphPath: "me", parameters: parameters)
        
        //formal request
        connection.add(request, completionHandler: {
            (connection, result, error) in
            print("Facebook graph Result:", result)
         
            print(JSONSerialization.isValidJSONObject(result!))
            
            do{
                let validJSONObject: Data? = try JSONSerialization.data(withJSONObject: result!, options: JSONSerialization.WritingOptions.prettyPrinted)
                
                let jsonDict = try JSONSerialization.jsonObject(with: validJSONObject!, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String: AnyObject]
                
                self.name = jsonDict["name"] as! String?
                self.email = jsonDict["email"] as! String?
                self.facebookID = Int((jsonDict["id"] as! String?)!)
                let picture = jsonDict["picture"] as! [String: AnyObject]?
                let data = picture?["data"] as! [String: AnyObject]?
                self.profilePictureURL = data?["url"] as! String?
                
                print(self.profilePictureURL)
            }
            catch{
                print("json facebook fetch error")
            }

        })
        connection.start()
    }
    
    //update firebase with current vars
    
    //cache current vars
    
    //pull vars from cache
}
