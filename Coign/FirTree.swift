//
//  FirTree.swift
//  Coign
//
//  Created by Maximilian Hoffman on 10/6/16.
//  Copyright © 2016 Exlent Studios. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import GeoFire

/**
 Contains all of the calls to and from the firebase database, including constants enums that replicates the firebase database structure.
        - Can call FirTree.rootRef anywhere in project
        - The database structure needs to be replicated here exactly, and all references to those nodes need to be called using the constants given here.
        * Can still be organized more neatly, but this is a good start.
 */
class FirTree {
    
    //MARK: - Properties
    static let rootRef = FIRDatabase.database().reference()
    static let database = FIRStorage.storage().reference()

 
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
    //TODO - model functions need to be written
    
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
    
    //MARK: - Image functions
    
    /**
     Pull user image from their image url, store in the Firebase storage database
     */
    class func getUserImage(completionHandler: @escaping (_ image: UIImage?) -> Void) {
        
        //vars needed
        let facebookID = UserDefaults.standard.object(forKey: FirTree.UserParameter.Id.rawValue) as! String
        
        //establish reference point for image
        let userImageRef = FirTree.database.child("user profile images/\(facebookID)")
        
        //check to see if we've already saved their picture
        userImageRef.data(withMaxSize: 1*1000*1000) {
            (data, error) in
            
            //if the reference has no data, then we need to fill it
            if error != nil {
                print(error?.localizedDescription ?? "no image was found at the given url")
                
                FirTree.updateUserDatabaseImage(facebookID: facebookID, completionHandler: { (image) in
                    completionHandler(image)
                })
            }
            
            //if the reference does have data, we can just return that as an image
            else if data != nil {
                let image = UIImage(data: data!)
                
                print("image already exists")
                completionHandler(image)
            }
        }
    }
    
    /**
     Updates the firebase storage image given the current url in defaults.
    */
    //TODO: This should probably be changed so that we make a facebook query to update the defaults and FirTree before updating FIR storage.
    class func updateUserDatabaseImage(facebookID: String, completionHandler: @escaping (_ image: UIImage?) -> Void) {
        
        //vars needed
        var image:UIImage? = nil
        let facebookID = UserDefaults.standard.object(forKey: FirTree.UserParameter.Id.rawValue)
        
        //establish reference point for image
        let userImageRef = FirTree.database.child("user profile images/\(facebookID!)")
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image/jpeg"
        
        //pull data from the user's picture url
        if let profileImageURL = UserDefaults.standard.object(forKey: FirTree.UserParameter.Picture.rawValue) as? String {
            
            URLSession.shared.dataTask(
                with: URL(string: profileImageURL)!)
            { (data, response, error) in
                
                //catch errors
                if error != nil {
                    print(error?.localizedDescription ?? "no image was found at the given url")
                }
                    
                else if data != nil {
                    
                    //save the data to return in completion handler
                    image = UIImage(data: data!)
                    
                    //put data in google cloud bucket
                    userImageRef.put(data!, metadata: metadata, completion: { (metadata, error) in
                        if error != nil {
                            print(error?.localizedDescription ?? "error uploading user image")
                        }
                    })
                }
                
                //finish the completion block by returning the user image
                completionHandler(image)
                
            }.resume()
        }
    }
    
    //set reference
//    let geofireRef = FIRDatabase.database().reference()
//    let geoFire = GeoFire(firebaseRef: geofireRef)
    
    //Geofire query example
//    let center = CLLocation(latitude: 37.7832889, longitude: -122.4056973)
//    // Query locations at [37.7832889, -122.4056973] with a radius of 600 meters
//    var circleQuery = geoFire.queryAtLocation(center, withRadius: 0.6)
//    
//    // Query location by region
//    let span = MKCoordinateSpanMake(0.001, 0.001)
//    let region = MKCoordinateRegionMake(center.coordinate, span)
//    var regionQuery = geoFire.queryWithRegion(region)
}
