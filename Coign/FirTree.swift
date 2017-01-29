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
        case FacebookIDs = "facebook ids"
        case CommunityProxies = "community proxies"
        case MonthlyTally = "monthly tally"
        case StripeID = "stripeID"
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
        case NetworkOfImpact = "network of impact"
        case StripeID = "stripe ID"
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
        case Anonymous = "anonymous"
        case LikeCount = "like count"
        case CommentCount = "comment count"
        case ReCoignCount = "recoign count"
        case RootPostId = "root post"
        case Proxy = "proxy"
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
    class func updateUser(_ withNewSettings: [String: Any]) -> Void {
        //retrieve facebookID
        if  let userID = UserDefaults.standard.string(forKey: UserParameter.UserUID.rawValue) {
            
            rootRef.child(Node.Users.rawValue).child(userID).updateChildValues(withNewSettings)
        }
        else {
            print("did not find user ID value in user defaults")
        }
    }
    
    //MARK: - New user function
    /**
     Adds a node to the "users" branch of the FIR tree - indexed by the user's facebook ID; used to create new user in "users" branch of FIR tree during loginControlFlow().
     */
    class func createNewUserInFirebase(_ userID: String, facebookID: String, name: String, pictureURL: String) {

        //prep data
        //TODO: make the "new user" node unnecessary somehowww
        let post: [String : Any] = [FirTree.UserParameter.Name.rawValue : name,
                                    FirTree.UserParameter.Picture.rawValue : pictureURL,
                                    FirTree.UserParameter.NetworkOfImpact.rawValue : [],
                                    FirTree.UserParameter.FacebookUID.rawValue: facebookID,
                                    FirTree.UserParameter.MostRecentLoginDate.rawValue: FirTree.UserParameter.NewUser.rawValue,
                                    FirTree.UserParameter.Friends.rawValue : []]
        
        //add date to new node
        rootRef.child(Node.Users.rawValue).child(userID).updateChildValues(post) {
        (error, snapshot) in
            
            //add picture to
            if error != nil {
                updateUserDatabaseImage(userID)
            }
        }
        
        //add user to facebookID's list
        rootRef.child(Node.FacebookIDs.rawValue).child(facebookID).updateChildValues([
            UserParameter.UserUID.rawValue: userID,
            UserParameter.Name.rawValue: name
        ])
        
        //update user defaults
        //TODO: change this so that we don't need the "new user" intermediary
        UserDefaults.standard.set(FirTree.UserParameter.NewUser.rawValue, forKey: FirTree.UserParameter.MostRecentLoginDate.rawValue)
        //store data in UserDefaults for later use
        UserDefaults.standard.set(facebookID, forKey: FirTree.UserParameter.FacebookUID.rawValue)
        UserDefaults.standard.set(name, forKey: FirTree.UserParameter.Name.rawValue)
        UserDefaults.standard.set(pictureURL, forKey: FirTree.UserParameter.Picture.rawValue)
        UserDefaults.standard.set(userID, forKey: FirTree.UserParameter.UserUID.rawValue)
    }
    
    class func updateUserFriends(_ friends: [[String:AnyObject]]) {

        var fireFriendsDict = [String: String]()
        let group = DispatchGroup()
        
        friends.forEach({ (friend) in
            
            group.enter()
            
            if let friendFBUID = friend["id"] as? String, let friendName = friend["name"] as? String {
                
                self.rootRef.child(Node.FacebookIDs.rawValue).child(friendFBUID).observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if let friendNode = snapshot.value as? [String : String],
                        let friendUID = friendNode[UserParameter.UserUID.rawValue]
                    {
                        fireFriendsDict[friendName] = friendUID
                        group.leave()
                    }
                })
            }
        })
        
        group.notify(queue: DispatchQueue.main) {
            //put the friends array in userdefaults for convenience
            self.updateUser([UserParameter.Friends.rawValue: fireFriendsDict])
            print(fireFriendsDict)
        }
        
    }
    
    class func newCommunityProxy(name: String) -> String {
        let newUID = UUID().uuidString
        rootRef.child(Node.CommunityProxies.rawValue).updateChildValues([
            newUID: name])
        
        return newUID
    }
}
