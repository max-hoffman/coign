//
//  ImageExtensions.swift
//  Coign
//
//  Created by Maximilian Hoffman on 11/13/16.
//  Copyright © 2016 Exlent Studios. All rights reserved.
//

import Foundation
import FirebaseStorage

extension FirTree {
    
    //MARK: - Image functions
    
    /**
     Pull user image from their image url, store in the Firebase storage database.
     */
    class func returnCurrentUserImage(completionHandler: @escaping (_ image: UIImage?) -> Void) {
        
        //vars needed
        let userID = UserDefaults.standard.object(forKey: FirTree.UserParameter.UserUID.rawValue) as! String
        
        //establish reference point for image
        let userImageRef = FirTree.database.child("user profile images/\(userID)")
        
        //check to see if we've already saved their picture
        userImageRef.data(withMaxSize: 1*1000*1000) {
            (data, error) in
            
            //if the reference has no data, then we need to fill it
            if error != nil {
                print(error?.localizedDescription ?? "no image was found at the given url")
                
                FirTree.updateUserDatabaseImage(userID: userID, completionHandler: { (image) in
                    completionHandler(image)
                })
            }
                
                //if the reference does have data, we can just return that as an image
            else if data != nil {
                if let image = UIImage(data: data!) {
                    completionHandler(image)
                }
            }
        }
    }
    
    /**
     Updates the firebase storage image given the current url in defaults.
     */
    //TODO: This should probably be changed so that we make a facebook query to update the defaults and FirTree before updating FIR storage.
    class func updateUserDatabaseImage(userID: String, completionHandler: @escaping (_ image: UIImage?) -> Void) {
        
        //vars needed
        var image:UIImage? = nil
        
        //establish reference point for image
        let userImageRef = FirTree.database.child("user profile images/\(userID)")
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
    
    class func updateUserDatabaseImage(userID: String) {
        
        //establish reference point for image
        let userImageRef = FirTree.database.child("user profile images/\(userID)")
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
                    
                    //put data in google cloud bucket
                    userImageRef.put(data!, metadata: metadata, completion: { (metadata, error) in
                        if error != nil {
                            print(error?.localizedDescription ?? "error uploading user image")
                        }
                    })
                }
                
            }.resume()
        }
    }

    /**
     Gets an image given the user UID. 
     
     //TODO: - Overloaded method that takes URL might be a good idea in the future.
    */
    class func returnImage(userID: String, completionHandler: @escaping (_ image: UIImage) -> Void) {
        
        //establish reference point for image
        let userImageRef = FirTree.database.child("user profile images/\(userID)")
        
        //check to see if we've already saved their picture
        userImageRef.data(withMaxSize: 1*1000*1000) {
            (data, error) in
            
            //if the reference has no data, then we need to fill it
            if error != nil {
                print(error?.localizedDescription ?? "no image was found at the given url")
            }
                
                //if the reference does have data, we can just return that as an image
            else if data != nil {
                if let image = UIImage(data: data!) {
                    completionHandler(image)
                }
            }
        }
    }
}
