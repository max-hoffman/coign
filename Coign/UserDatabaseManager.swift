//
//  UserDatabaseManager.swift
//  Coign
//
//  Created by Maximilian Hoffman on 10/2/16.
//  Copyright © 2016 Exlent Studios. All rights reserved.
//

import Foundation
import Firebase

class UserDataBaseManager {
    
    static let sharedInstance = UserDataBaseManager()
    
    //MARK: - properties
//    var name: String? = nil
//    var email: String? = nil
//    var friendsList: [Int]? = nil
//    var preferredCharity: String? = nil
//    var profilePictureURL: String? = nil
    var facebookID: Int? = nil
    var timeSinceFBSDKUpdate: String? = nil
    
    
    //MARK: - class functions
    
    /**
     Fetch fb data (name / friendlist / picture), update FIR tree
    */
    private func fetchFBSDKInfo(parameters: [String]) -> [String : Any] {
        var returnDict: [String : Any]
        
        //make graph request, parse JSON data
        //request parameters
        let connection = FBSDKGraphRequestConnection()
        let parameters = ["fields":"email, name, id, picture.type(large), friends"]
        let request = FBSDKGraphRequest.init(graphPath: "me", parameters: parameters)
        self.timeSinceFBSDKUpdate = Date().shortDate
        
        //formal request
        connection.add(request, completionHandler: {
            (connection, result, error) in
            print("Facebook graph Result:", result)
            
            print(JSONSerialization.isValidJSONObject(result!))
            
            do{
                let validJSONObject: Data? = try JSONSerialization.data(withJSONObject: result!, options: JSONSerialization.WritingOptions.prettyPrinted)
                
                let jsonDict = try JSONSerialization.jsonObject(with: validJSONObject!, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String: AnyObject]
                
//                self.name = jsonDict["name"] as! String?
//                self.email = jsonDict["email"] as! String?
//                self.facebookID = Int((jsonDict["id"] as! String?)!)
//                let picture = jsonDict["picture"] as! [String: AnyObject]?
//                let data = picture?["data"] as! [String: AnyObject]?
//                self.profilePictureURL = data?["url"] as! String?
//                
//                print(self.profilePictureURL)
//                print(self.name)
//                print(self.email)
//                print(self.facebookID)
            }
            catch{
                print("json facebook fetch error")
            }
            
        })
        connection.start()

        return returnDict
    }
    
    /**
     Make a new user node in FIR tree
     */
    func newUser(node: FIRDatabaseReference) -> Void {
        //fetchFBSDKInfo
        
        //replace the FIR-ID with the facebookID
        
        //create new node in FIR tree, pass data from FBSDK fetch

//        node.child("Users").child("\(facebookID)").setValue(userDict)
//        print("\(facebookID) should contain \(userDict)")
    }
    
    /**
     Update on-device cache, everything sits in background
    */
    func cacheUserData(node: FIRDatabaseReference) -> Void {
        
    }
    
    /**
     Update multiple user settings
    */
    func updateUserSettings(node: FIRDatabaseReference, newSettings: [String: Any]) -> Void {
        //need to get facebookID
    }
    
    /**
     Update Individual user setting
    */
    func updateUserSetting(node: FIRDatabaseReference, key: String, value: Any ) -> Void {
        //need to get facebookID
    }
    
    /**
     Post donation to FIR tree; update "users" nodes and "donations" nodes
    */
    func postDonation(node: FIRDatabaseReference, donationDetails: [String: Any]) {
        //need to get facebookID
    }
    
    /**
     Update donation message text.
    */
    func updateDonationMessage(messageID: String, newMessage newValue: String) {
        
    }
    
}
