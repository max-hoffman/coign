//
//  FirTree.swift
//  Coign
//
//  Created by Maximilian Hoffman on 10/6/16.
//  Copyright © 2016 Exlent Studios. All rights reserved.
//

import UIKit
import Firebase

class FirTree {
    
    //MARK: - Properties
    //var rootRef: FIRDatabaseReference?
    static let rootRef = FIRDatabase.database().reference()
 
    //MARK: - Internal data structure
    enum Node: String {
        case Users = "users"
        case Donations = "donations"
    }


    enum UserParameter: String {
        case Name = "name"
        case Email = "email"
        case Birthday = "birthday"
        case Phone = "phone number"
        case Picture = "picture"
        case Friends = "friends"
        case MostRecentLoginDate = "most recent login date"
        case NewUser = "new user"
        case Id = "facebookID"
        case Donations = "donations"
        case Charity = "charity preference"
    }
    
    enum DonationParameter: String {
        case Charity = "charity"
        case Donor = "donor"
        case Recipient = "recipient"
        case Date = "date"
        case Message = "message"
    }

    //MARK: - Public functions
    //TODO: - model functions need to be written
    
    /**
     Update user setting(s). Access valid parameter in FirTree enum.
     */
    class func updateUser(withNewSettings: [String: Any]) -> Void {
        //retrieve facebookID
        if  let facebookID = UserDefaults.standard.string(forKey: UserParameter.Id.rawValue) {
            //rootRef.child(Node.Users.rawValue).child(facebookID).setValue(withNewSettings)
            rootRef.child(Node.Users.rawValue).child(facebookID).updateChildValues(withNewSettings)
        }
    }
    
//    func fetchUser(settings: [UserParameter: Any]) -> [UserParameter: Any] {
//        
//        
//        return data
//    }
    
    /**
     Post donation to FIR tree; update "users" nodes and "donations" nodes
     */
    func newDonation(donor: String, charity: String, recipient: String?, message: String) {
        
        //make sure the user's logged in
        if  let _ = UserDefaults.standard.string(forKey: UserParameter.Id.rawValue) {
            
            //TODO: access the date somehow, maybe just do milliseconds since 1970
            let date = "date"
            
            //organize donation info
            let donation = [DonationParameter.Charity.rawValue: charity,
                            DonationParameter.Donor.rawValue: donor,
                            DonationParameter.Recipient.rawValue: recipient,
                            DonationParameter.Date.rawValue: date,
                            DonationParameter.Message.rawValue: message]
            
            //create donation node with a unique ID
            let donationRef = FirTree.rootRef.child(Node.Donations.rawValue).childByAutoId()
            
            //add the donation info to that node
            donationRef.updateChildValues(donation)
            
            //record that donation event in the user's donation node (array of ID's)
            FirTree.rootRef.child(Node.Users.rawValue).child(UserParameter.Donations.rawValue).setValue(donationRef)
        }
    }
    
    /**
     Update donation message text.
     */
    func updateDonationMessage(messageID: String, newMessage newValue: String) {
        
    }
}
