//
//  PostingExtensions.swift
//  Coign
//
//  Created by Maximilian Hoffman on 11/13/16.
//  Copyright © 2016 Exlent Studios. All rights reserved.
//

import Foundation
import Firebase
import CoreLocation
import FirebaseStorage
import FirebaseDatabase

extension FirTree {
    
    //TODO: change this to update the recipient and user networks of impact -> array with charity and count
    
    /**
     Post donation to FIR tree; update "users" nodes and "donations" nodes
     */
    class func newPost(_ post: [String: Any], location: CLLocationCoordinate2D?, completionHandler: (_ postID: String?) -> ()) {

        if let userID = post[PostParameter.DonorUID.rawValue] as? String, let charity = post[PostParameter.Charity.rawValue] as? String {
            let proxyUID = post[PostParameter.RecipientUID.rawValue] as? String
            let proxyIsAFriend = post[PostParameter.ProxyIsFriend.rawValue] as? String

            //MARK: Post data
            
            //create donation node with a unique ID
            let postRef = FirTree.rootRef.child(Node.Posts.rawValue).childByAutoId()
            
            //add the donation info to that node
            postRef.updateChildValues(post)
            
            //TODO: this is lazy af, need to make this nicer. the fix is to probably pass in a bunch of parameters to this funciton and assemble the post inside
            postRef.updateChildValues([FirTree.PostParameter.PostUID.rawValue: postRef.key])
            
            //MARK: Geohash data
            
            //set geohash with that ID reference
            Geohash.setGeohash(location, postUID: postRef.key)
            
            //MARK: User data
            
            updateUserNetworkOfImpact(userID: userID, charity: charity)
            
            //record that donation event in the user's donation node (array of ID's)
            FirTree.rootRef.child(Node.Users.rawValue).child(userID).child(UserParameter.Posts.rawValue).updateChildValues([postRef.key: true])
            
            
            //MARK: Recipient data

            //update the recipient node if necessary
            if proxyUID != nil {
                
                updateUserNetworkOfImpact(userID: proxyUID!, charity: charity)
                
                //record that donation event in the recipient's donation node
                FirTree.rootRef.child(Node.Users.rawValue).child(proxyUID!).child(UserParameter.Posts.rawValue).setValue(postRef.key)
            }
            
            //MARK: Update monthly chart
            recordPostInMonthlyChart(charity: charity)
            
            completionHandler(postRef.key)
            return
        }
        completionHandler(nil)
        return
    }
    
    class func recordPostInMonthlyChart(charity: String) {
        
        rootRef.child(Node.MonthlyTally.rawValue).child(Date().monthYear).child(charity).runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
            
            let currentCount = currentData.value as? Int ?? 0
            currentData.value = currentCount + 1
            return FIRTransactionResult.success(withValue: currentData)
            
        }) { (error, committed, snapshot) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    class func updateUserNetworkOfImpact(userID: String, charity: String) {
        
        FirTree.rootRef.child(Node.Users.rawValue).child(userID).child(FirTree.UserParameter.NetworkOfImpact.rawValue).child(charity).runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
            
            let currentCount = currentData.value as? Int ?? 0
            currentData.value = currentCount + 1
            return FIRTransactionResult.success(withValue: currentData)
            
        }) { (error, committed, snapshot) in
            if let error = error {
                print(error.localizedDescription)
            }
        }

    }
    
    func recordDonation(charity: String) {
        
    }
    
    /**
     Update donation message text.
     */
    func updateDonationMessage(_ messageID: String, newMessage newValue: String) {
        
    }
}
