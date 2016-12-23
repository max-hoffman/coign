//
//  QueryExtensions.swift
//  Coign
//
//  Created by Maximilian Hoffman on 11/17/16.
//  Copyright © 2016 Exlent Studios. All rights reserved.
//

import Foundation
import Firebase
import CoreLocation
import FirebaseDatabase
import FirebaseStorage

extension FirTree {
    
    /**
     This function recieives an array of strings, and should return an array of posts in a completion handler.
     */
    class func returnPostsFromUIDs(_ postUIDs: [String], completionHandler: @escaping (_ newPosts: [Post]) -> Void) {
       
    let firstGroup = DispatchGroup()
        
    var newPosts: [Post] = []
    var newPost: Post?
        
        for postUID in postUIDs {
            
            firstGroup.enter()
            
            rootRef.child(FirTree.Node.Posts.rawValue).child(postUID).observeSingleEvent(of: .value, with: { snapshot in

                if let post = snapshot.value as? [String: Any] {
                    
                    newPost = Post(
                        poster: post[FirTree.PostParameter.DonorName.rawValue] as? String,
                        posterUID: post[FirTree.PostParameter.DonorUID.rawValue] as? String,
                        proxy: post[FirTree.PostParameter.RecipientName.rawValue] as? String,
                        message: post[FirTree.PostParameter.Message.rawValue] as? String,
                        timeStamp: post[FirTree.PostParameter.TimeStamp.rawValue] as? Int,
                        charity: post[FirTree.PostParameter.Charity.rawValue] as? String,
                        postUID: post[FirTree.PostParameter.PostUID.rawValue] as? String,
                        anonymous: post[FirTree.PostParameter.Anonymous.rawValue] as? Bool)
                    
                    newPosts.append(newPost!)
                    
                }
                firstGroup.leave()
            })
        }
    
        firstGroup.notify(queue: DispatchQueue.main) {
            completionHandler(newPosts)
        }
    }
    
    /**
     Return an array of recent post UID's, that are converted to posts as needed by the above function.
     */
    class func queryRecentPosts(_ number: Int, completionHandler: @escaping (_ recentPostUIDs: [String]?) -> Void) {
        
        var recentPosts: [String] = []
        
        rootRef.child(Node.Posts.rawValue).queryLimited(toFirst: UInt(number)).observe( .value, with: { snapshot in
                
            for item in snapshot.children {
                if let child = item as? FIRDataSnapshot, let post = child.value,
                    let postDict = JSONParser.parseJSON(post),
                    let postUID = postDict[FirTree.PostParameter.PostUID.rawValue] as? String {
                        recentPosts.insert(postUID, at: 0)
                }
            }
            completionHandler(recentPosts)
        })
        
    }
    
    /**
     Return an array of friend post UID's sorted by time, to be fed into retrunPostFromUID as needed.
     */
    class func queryFriendPosts (_ completionHandler: @escaping (_ postUIDs: [String]?) -> Void) {
        
    }
    
    class func queryFriends(completionHandler: @escaping (_ friends: [String]?, _ friendsDict: [String:String]?) -> Void) {
        var friendsArray: [String]?
        var friendsDict: [String: String]?
        let dispatchThread = DispatchGroup()
        
        if let userID = UserDefaults.standard.object(forKey: UserParameter.UserUID.rawValue) as? String {
        
            dispatchThread.enter()
            rootRef.child(Node.Users.rawValue).child(userID).child(UserParameter.Friends.rawValue).observeSingleEvent(of: .value, with: {
                snapshot in
                
                if let friends = snapshot.value as? [String: String] {
                    friendsArray = friends.map{$0.key}
                    friendsDict = friends
                }
                
                dispatchThread.leave()
            })
            
            dispatchThread.notify(queue: DispatchQueue.main) {
                completionHandler(friendsArray, friendsDict)
            }
        }
    }
    
    class func queryCommunityProxies(completionHandler: @escaping (_ proxyArray: [String]?, _ proxyDict: [String:String]?) -> Void) {
        var proxyArray: [String]?
        var proxyDict: [String: String]?
        let dispatchThread = DispatchGroup()
        
        dispatchThread.enter()
        rootRef.child(Node.CommunityProxies.rawValue).observeSingleEvent(of: .value, with: {
            snapshot in
            
            if let proxies = snapshot.value as? [String:String] {
                proxyArray = proxies.map{$1}
                proxyDict = proxies
            }
            
            dispatchThread.leave()
        })
        
        dispatchThread.notify(queue: DispatchQueue.main) { completionHandler(proxyArray, proxyDict) }
    }
    
    class func queryNetworkOfImpact(userID: String, completionHandler: @escaping (_ networkCounts: [(String, String)]?) -> Void) {
        
        var networkOfImpact: [(charity: String, number: String)]?
        let dispatchThread = DispatchGroup()
        
        dispatchThread.enter()
        rootRef.child(Node.Users.rawValue).child(userID).child(UserParameter.NetworkOfImpact.rawValue).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let networkNode = snapshot.value as? [String: String] {
                networkOfImpact = networkNode.map { ($0, $1) }
            }
            dispatchThread.leave()
        })
        
        dispatchThread.notify(queue: DispatchQueue.main) { completionHandler(networkOfImpact) }
    }

}
