//
//  Geohash.swift
//  Coign
//
//  Created by Maximilian Hoffman on 11/13/16.
//  Copyright © 2016 Exlent Studios. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorage
import GeoFire
import FirebaseDatabase

class Geohash {
    
    class func setGeohash(location: CLLocationCoordinate2D?, postUID: String) {
        
        if  location != nil {
            let postLocation = CLLocation(latitude: location!.latitude, longitude: location!.longitude)
            
            //set reference
            let geofireRef = FIRDatabase.database().reference().child("post locations")
            let geoFire = GeoFire(firebaseRef: geofireRef)

            //store location for the given post ID
            geoFire?.setLocation(postLocation, forKey: postUID)
        }
    }
    
    
    class func queryLocalPosts (center: CLLocation, completionHandler: @escaping (_ postData: [String]?) -> Void) {
        
        var postData: [String] = []
       
        //set reference
        let geofireRef = FIRDatabase.database().reference().child("post locations")
        let geoFire = GeoFire(firebaseRef: geofireRef)
        
        let circleQuery = geoFire?.query(at: center, withRadius: 15)
        
        var _ = circleQuery?.observe(.keyEntered, with: { (key, location) in
            
            
            postData.insert(key!, at: 0)
        })
       
        circleQuery?.observeReady({
            completionHandler(postData.sorted{$0 > $1})
        })
    }
}
