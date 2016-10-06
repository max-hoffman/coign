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
    
    //static let sharedInstance = UserDataBaseManager()
    let rootRef = FIRDatabase.database().reference()
    
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
     Parse JSON data
        - param validJSONObject: takes the result from FBSDK Graph request
        - returns: JSON dictionary
    */
    private func parseJSON(validJSONObject: Any) -> [String : Any]? {
        
        var jsonDict: [String: Any]?
        
        if(JSONSerialization.isValidJSONObject(validJSONObject)){
            do {
                let JSONData: Data? = try JSONSerialization.data(withJSONObject: validJSONObject, options: JSONSerialization.WritingOptions.prettyPrinted)
            
                jsonDict = try JSONSerialization.jsonObject(with: JSONData!, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String: AnyObject]
            }
            catch {
                print(error.localizedDescription)
                return jsonDict
            }
        }
        return jsonDict
    }
    
    /**
     Fetch fb data (name / friendlist / picture), update FIR tree
        - param parameters: of form ["fields" : "email, name, picture.type(large), friends"]
     
        -returns Dictionary: key/value pairs of facebook graph request
    */
    private func fetchFBSDKInfo(parameters: [String: Any]) -> [String : Any]? {
        var returnDict: [String : Any]?
        
        //make graph request, parse JSON data
        let connection = FBSDKGraphRequestConnection()
        let request = FBSDKGraphRequest.init(graphPath: "me", parameters: parameters)
        //self.timeSinceFBSDKUpdate = Date().shortDate
        
        //formal request
        connection.add(request, completionHandler: {
            [weak weakSelf = self]
            (connection, result, error) in
            
            if error != nil {
                print(error?.localizedDescription)
                print("error in fb call")
                return
            }
            print("Facebook graph Result:", result)
            
            print(JSONSerialization.isValidJSONObject(result!))
            returnDict = weakSelf?.parseJSON(validJSONObject: result)
//            do{
//                let validJSONObject: Data? = try JSONSerialization.data(withJSONObject: result!, options: JSONSerialization.WritingOptions.prettyPrinted)
//                
//                let jsonDict = try JSONSerialization.jsonObject(with: validJSONObject!, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String: AnyObject]
//                
////                self.name = jsonDict["name"] as! String?
////                self.email = jsonDict["email"] as! String?
////                self.facebookID = Int((jsonDict["id"] as! String?)!)
////                let picture = jsonDict["picture"] as! [String: AnyObject]?
////                let data = picture?["data"] as! [String: AnyObject]?
////                self.profilePictureURL = data?["url"] as! String?
////                
////                print(self.profilePictureURL)
////                print(self.name)
////                print(self.email)
////                print(self.facebookID)
//            }
//            catch{
//                print("json facebook fetch error")
//            }
            
        })
        connection.start()

        return returnDict
    }
    
    /**
     Check if the user is new or not
    */
    func IsUserNew() {
        
        //make graph request
        let graphParameters = ["fields": "facebookID"]
        let jsonDict = self.fetchFBSDKInfo(parameters: graphParameters)
        
        if let id = jsonDict?["id"] as! String! {
            self.facebookID = Int(id)
            print(facebookID)
        }
        else {
            print("facebook fetch or JSON parsing error")
        }
        
        //check with firebase to see if user with the given facebookID exists
        
        
        //return true or false, depending on whether we find user w/ the given ID
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
