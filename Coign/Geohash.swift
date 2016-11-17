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
    
    
    //Geofire query example
    //    let center = CLLocation(latitude: 37.7832889, longitude: -122.4056973)
    //    // Query locations at [37.7832889, -122.4056973] with a radius of 600 meters
    //    var circleQuery = geoFire.queryAtLocation(center, withRadius: 0.6)
    //
    //    // Query location by region
    //    let span = MKCoordinateSpanMake(0.001, 0.001)
    //    let region = MKCoordinateRegionMake(center.coordinate, span)
    //    var regionQuery = geoFire.queryWithRegion(region)

}
