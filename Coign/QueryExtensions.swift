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
    
    //pull the 50 most recent posts from firebase
    class func queryRecentPosts(completionHandler: @escaping (_ postData: [Post]?) -> Void) {
        
        var postArray: [Post] = []
        
        rootRef.child("posts").queryLimited(toFirst: 50).observe(
            .value, with: { snapshot in
                
            for item in snapshot.children {
                if let child = item as? FIRDataSnapshot, let post = child.value,
                let postDict = JSONParser.parseJSON(validJSONObject: post) {
                    let newPost = Post(
                        donor: postDict[FirTree.PostParameter.DonorName.rawValue] as? String,
                        donorUID: postDict[FirTree.PostParameter.DonorUID.rawValue] as? String,
                               recipient: postDict[FirTree.PostParameter.RecipientName.rawValue] as? String,
                        message: postDict[FirTree.PostParameter.Message.rawValue] as? String,
                        timeStamp: postDict[FirTree.PostParameter.TimeStamp.rawValue] as? Int,
                        charity: postDict[FirTree.PostParameter.Charity.rawValue] as? String,
                        postUID: postDict[FirTree.PostParameter.PostUID.rawValue] as? String,
                        anonymous: postDict[FirTree.PostParameter.Anonymous.rawValue] as? Bool)
                    postArray.insert(newPost, at: 0)
                }
            }
            completionHandler(postArray)
        })

    }
    
    class func queryFriendPosts (completionHandler: @escaping (_ postData: [Post]?) -> Void) {
        
    }
    
}
