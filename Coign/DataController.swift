//
//  DataController.swift
//  Coign
//
//  Created by Maximilian Hoffman on 10/6/16.
//  Copyright © 2016 Exlent Studios. All rights reserved.
//

import UIKit
import Firebase

class DataController: UIViewController {
    
    //MARK: - Properties
    var rootRef: FIRDatabaseReference?
    var facebookID: Int? = nil
 
    //MARK: - Public functions
    
    /**
     Check if the user is new or not
     */
    private func IsUserNew(parameters: [String: Any]) {
        
        var jsonData: [String: Any]?
        
        let connection = FBSDKGraphRequestConnection()
        let request = FBSDKGraphRequest.init(graphPath: "me", parameters: parameters)
        connection.add(request, completionHandler: {
            [weak weakSelf = self]
            (connection, result, error) in
            
            jsonData = weakSelf?.parseJSON(validJSONObject: result)
            })
        
        connection.start()
        
        print(jsonData)
        //check with firebase to see if user with the given facebookID exists
        
        
        //return true or false, depending on whether we find user w/ the given ID
    }

    //MARK: - Private functions
    
    
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
            returnDict = weakSelf?.parseJSON(validJSONObject: result as! Data)
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
     Parse JSON data
     - param validJSONObject: takes the result from FBSDK Graph request
     - returns: JSON dictionary
     */
    public func parseJSON(validJSONObject: Any?) -> [String : Any]? {
        
        var jsonDict: [String: Any]?
        
        let validJSONData: Data?

        do{
            validJSONData = try JSONSerialization.data(withJSONObject: validJSONObject!, options: JSONSerialization.WritingOptions.prettyPrinted)

            jsonDict = try JSONSerialization.jsonObject(with: validJSONData!, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String: AnyObject]

            print(jsonDict?["name"])
        }
        catch{
            print("json error")
        }
        return jsonDict
    }


    func practiceFetchProfile(parameters: [String: Any]) -> [String: Any]? {
        
        var jsonData: [String: Any]?
        
        let connection = FBSDKGraphRequestConnection()
        let request = FBSDKGraphRequest.init(graphPath: "me", parameters: parameters)
        connection.add(request, completionHandler: {
            [weak weakSelf = self]
            (connection, result, error) in

            jsonData = weakSelf?.parseJSON(validJSONObject: result)
        })
    
        connection.start()
        
        print(jsonData)
        return jsonData
    }

    
    
    
    
    
    
    
    
    
    //MARK: - Superclass functions
    override func viewDidLoad() {
        super.viewDidLoad()
        rootRef = FIRDatabase.database().reference()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
