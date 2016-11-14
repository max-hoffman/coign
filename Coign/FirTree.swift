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
        case Posts = "posts"
        case Likes = "likes"
        case Comments = "comments"
        case ReCoigns = "recoigns"
        case Notifications = "notifications"
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
        case Posts = "posts"
        case Charity = "charity preference"
        case IncomingCoigns = "incoming"
        case OutgoingCoigns = "outgoing"
    }

    enum PostParameter: String {
        case PostUID = "post uid"
        case Donor = "donor"
        case Recipient = "recipient"
        case Charity = "charity"
        case DonationAmount = "donation amount"
        case Message = "message"
        case TimeStamp = "time stamp"
        case Location = "location"
        case SharedToFacebook = "shared to facebook"
        case Anonymous = "anonymous"
        case LikeCount = "like count"
        case CommentCount = "comment count"
        case ReCoignCount = "recoign count"
        case RootPostId = "root post"
    }
    
    enum NotificationParameter: String {
        case NotiicationUID = "notification uid"
        case From = "from"
        case Category = "Category" //
        case ForPost = "for post" //postUID
        case TimeStamp = "time stamp"
    }
    
    enum NotificationCategory: String {
        case Like = "like"
        case Comment = "comment"
        case ReCoign = "recoign"
    }
    
    //likes -- just an array of user id's
    //comments -- just a dict of user id : comment string
    //reposts -- just an array of user id's
    
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
}
