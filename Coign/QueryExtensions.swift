//
//  QueryExtensions.swift
//  Coign
//
//  Created by Maximilian Hoffman on 11/17/16.
//  Copyright © 2016 Exlent Studios. All rights reserved.
//

import Foundation
import Firebase

extension FirTree {
    
    //pull the 50 most recent posts from firebase
    class func queryRecentPosts(completionHandler: @escaping (_ postData: [[String:Any]]?) -> Void) {
        
        var postArray: [[String:Any]] = []
        
        rootRef.child("posts").queryLimited(toFirst: 50).observe(
            .value, with: { snapshot in
                
            for item in snapshot.children {
                if let child = item as? FIRDataSnapshot, let post = child.value,
                let postDict = JSONParser.parseJSON(validJSONObject: post) {
                    postArray.append(postDict)
                }
            }
            completionHandler(postArray)
        })

    }
}
