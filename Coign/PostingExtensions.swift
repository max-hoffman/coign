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
    class func newPost(_ post: [String: Any], location: CLLocationCoordinate2D?, userID: String, proxyUID: String?, proxyIsAFriend: Bool) {
        
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
        //record that donation event in the user's donation node (array of ID's)
        FirTree.rootRef.child(Node.Users.rawValue).child(userID).child(UserParameter.Posts.rawValue).updateChildValues([postRef.key: true])
        
        //TODO: change to network of impact
        //increment user outgoing post counter
//        FirTree.rootRef.child(Node.Users.rawValue).child(userID).child(FirTree.UserParameter.OutgoingCoigns.rawValue).runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
//            if var outgoingCount = currentData.value as? Int {
//                
//                //update the count
//                outgoingCount += 1
//                
//                // Set value and report transaction success
//                currentData.value = outgoingCount
//                
//                return FIRTransactionResult.success(withValue: currentData)
//            }
//            return FIRTransactionResult.success(withValue: currentData)
//        }) { (error, committed, snapshot) in
//            if let error = error {
//                print(error.localizedDescription)
//            }
//        }
        
        //MARK: Recipient data

        //update the recipient node if necessary
        if proxyUID != nil {
            //record that donation event in the recipient's donation node
            //FirTree.rootRef.child(Node.Users.rawValue).child(proxyUID!).child(UserParameter.Posts.rawValue).setValue(postRef.key: true)
            
            //TODO: change to network of impact
            //increment user outgoing post counter
//            FirTree.rootRef.child(Node.Users.rawValue).child(userID).child(FirTree.UserParameter.IncomingCoigns.rawValue).runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
//
//                
//                if var incomingCount = currentData.value as? Int  {
//                    
//                    //update the count
//                    incomingCount += 1
//                    
//                    // Set value and report transaction success
//                    currentData.value = incomingCount
//                    
//                    return FIRTransactionResult.success(withValue: currentData)
//                }
//                return FIRTransactionResult.success(withValue: currentData)
//            }) { (error, committed, snapshot) in
//                if let error = error {
//                    print(error.localizedDescription)
//                }
//            }
        }
    }
    
    /**
     Update donation message text.
     */
    func updateDonationMessage(_ messageID: String, newMessage newValue: String) {
        
    }
}
