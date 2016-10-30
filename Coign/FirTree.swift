//
//  FirTree.swift
//  Coign
//
//  Created by Maximilian Hoffman on 10/6/16.
//  Copyright © 2016 Exlent Studios. All rights reserved.
//

import UIKit
import Firebase

/**
 Contains all of the calls to and from the firebase database, including constants enums that replicates the firebase database structure.
        - Can call FirTree.rootRef anywhere in project
        - The database structure needs to be replicated here exactly, and all references to those nodes need to be called using the constants given here.
        * Can still be organized more neatly, but this is a good start.
 */
class FirTree {
    
    //MARK: - Properties
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
     Update user setting(s). Access valid parameters in FirTree.UserParameters or FirTree.DonationParameters enums.
     */
    class func updateUser(withNewSettings: [String: Any]) -> Void {
        //retrieve facebookID
        if  let facebookID = UserDefaults.standard.string(forKey: UserParameter.Id.rawValue) {
            
            rootRef.child(Node.Users.rawValue).child(facebookID).updateChildValues(withNewSettings)
        }
        else {
            print("did not find facebook ID value in user defaults")
        }
    }
    
//    func fetchUser(settings: [UserParameter], completion: @escaping ([UserParameter: Any]?) -> ()) {
//        var data = [UserParameter: Any]()
//        if  let facebookID = UserDefaults.standard.string(forKey: UserParameter.Id.rawValue) {
//
//            FirTree.rootRef.child(Node.Users.rawValue).child(facebookID).observeSingleEvent(of: .value, with: { (snapshot) in
//                
//                let value = snapshot.value as? NSDictionary
//                
//                for setting in settings {
//                    data[setting] = value?[setting]
//                }
//                completion(data)
//            })
//        }else {
//            completion(nil)
//        }
//        
//    }
    
    /**
     Post donation to FIR tree; update "users" nodes and "donations" nodes
     */
    class func newDonation(donor: String, charity: String, recipient: String?, message: String) {
        
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
