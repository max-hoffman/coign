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
 
    //MARK: - Public functions


    //TODO: - model functions need to be written
    
    /**
     Update on-device cache, everything sits in background
     */
    func cacheUserData(node: FIRDatabaseReference) -> Void {
        
    }
    
    /**
     Update multiple user settings
     */
    func updateUserSettings(newSettings: [String: Any]) -> Void {
        //retrieve facebookID
        if  let facebookID = UserDefaults.standard.string(forKey: "facebookID") {
            self.rootRef?.child("users").child(facebookID).setValue(newSettings)
        }
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
