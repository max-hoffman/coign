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

extension FirTree {
    
    /**
     This function gets an array of strings, and should return an array of postsin a completion handler.
     */
    class func returnPostsFromUIDs(postUIDs: [String], completionHandler: @escaping (_ newPosts: [Post]) -> Void) {
       
    let firstGroup = DispatchGroup()
        
    var newPosts: [Post] = []
    var newPost: Post?
        
        for postUID in postUIDs {
            
            firstGroup.enter()
            
            rootRef.child(FirTree.Node.Posts.rawValue).child(postUID).observeSingleEvent(of: .value, with: { snapshot in

                if let post = snapshot.value as? [String: Any] {
                    
                    newPost = Post(
                        donor: post[FirTree.PostParameter.DonorName.rawValue] as? String,
                        donorUID: post[FirTree.PostParameter.DonorUID.rawValue] as? String,
                        recipient: post[FirTree.PostParameter.RecipientName.rawValue] as? String,
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
     Return an array of recent post UID's, that are converted to posts as needed.
     */
    class func queryRecentPosts(number: Int, completionHandler: @escaping (_ recentPostUIDs: [String]?) -> Void) {
        
        var recentPosts: [String] = []
        
        rootRef.child("posts").queryLimited(toFirst: UInt(number)).observe( .value, with: { snapshot in
                
            for item in snapshot.children {
                if let child = item as? FIRDataSnapshot, let post = child.value,
                    let postDict = JSONParser.parseJSON(validJSONObject: post),
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
    class func queryFriendPosts (completionHandler: @escaping (_ postUIDs: [String]?) -> Void) {
        
    }
}
