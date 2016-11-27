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
import FirebaseDatabase
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
        case FacebookUID = "facebook uid"
        case UserUID = "user uid"
        case Posts = "posts"
        case Charity = "charity preference"
        case IncomingCoigns = "incoming"
        case OutgoingCoigns = "outgoing"
    }

    enum PostParameter: String {
        case PostUID = "post uid"
        case DonorUID = "donor uid"
        case DonorName = "donor name"
        case RecipientUID = "recipient uid"
        case RecipientName = "recipient name"
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
        if  let userID = UserDefaults.standard.string(forKey: UserParameter.UserUID.rawValue) {
            
            rootRef.child(Node.Users.rawValue).child(userID).updateChildValues(withNewSettings)
        }
        else {
            print("did not find facebook ID value in user defaults")
        }
    }
    
    //MARK: - New user function
    /**
     Adds a node to the "users" branch of the FIR tree - indexed by the user's facebook ID; used to create new user in "users" branch of FIR tree during loginControlFlow().
     */
    class func createNewUserInFirebase(userID: String, facebookID: String, name: String, pictureURL: String) {
        
        //prep data
        //TODO: make the "new user" node unnecessary by calling the
        let post: [String : Any] = [FirTree.UserParameter.Name.rawValue : name,
                                    FirTree.UserParameter.Picture.rawValue : pictureURL,
                                    FirTree.UserParameter.OutgoingCoigns.rawValue: 0,
                                    FirTree.UserParameter.IncomingCoigns.rawValue: 0,
                                    FirTree.UserParameter.FacebookUID.rawValue: facebookID,
                                    FirTree.UserParameter.MostRecentLoginDate.rawValue: FirTree.UserParameter.NewUser.rawValue]
        
        //add date to new node
        rootRef.child(Node.Users.rawValue).child(userID).updateChildValues(post) {
        (error, snapshot) in
            
            //add picture to
            if error != nil {
                updateUserDatabaseImage(userID: userID)
            }
        }
        
        //update user defaults
        //TODO: change this so that we don't need the "new user" intermediary
        UserDefaults.standard.set(FirTree.UserParameter.NewUser.rawValue, forKey: FirTree.UserParameter.MostRecentLoginDate.rawValue)
        //store data in UserDefaults for later use
        UserDefaults.standard.set(facebookID, forKey: FirTree.UserParameter.FacebookUID.rawValue)
        UserDefaults.standard.set(name, forKey: FirTree.UserParameter.Name.rawValue)
        UserDefaults.standard.set(pictureURL, forKey: FirTree.UserParameter.Picture.rawValue)
        UserDefaults.standard.set(userID, forKey: FirTree.UserParameter.UserUID.rawValue)
    }


}
