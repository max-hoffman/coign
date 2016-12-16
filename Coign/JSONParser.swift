//
//  JSONParser.swift
//  Coign
//
//  Created by Maximilian Hoffman on 11/17/16.
//  Copyright © 2016 Exlent Studios. All rights reserved.
//

import Foundation

struct JSONParser {
/**
 Parse JSON data
 - param validJSONObject: takes the result from FBSDK Graph request
 - returns: JSON dictionary
 */
static func parseJSON(_ validJSONObject: Any?) -> [String : Any]? {
    
    var jsonDict: [String: Any]?
    
    let validJSONData: Data?
    
    do{
        validJSONData = try JSONSerialization.data(withJSONObject: validJSONObject!, options: JSONSerialization.WritingOptions.prettyPrinted)
        
        jsonDict = try JSONSerialization.jsonObject(with: validJSONData!, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String: AnyObject]
    }
    catch{
        print("json error, invalid object passed: \(error.localizedDescription)")
    }
    return jsonDict
}
}
