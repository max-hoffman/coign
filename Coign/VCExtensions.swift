//
//  VCExtensions.swift
//  Coign
//
//  Created by Maximilian Hoffman on 10/7/16.
//  Copyright © 2016 Exlent Studios. All rights reserved.
//

import Foundation

extension UIViewController {
    
    //helps access proper view controller after segues; segueing to new storyboard puts you in nav controller, but you usually want the visible controller
    var contentViewController: UIViewController {
        if let navcon = self as? UINavigationController {
            return navcon.visibleViewController ?? self
        }
        else {
            return self
        }
    }
    
    func connectRevealVC() {
        if self.revealViewController() != nil {
            if let navcon = self.navigationController{
                let navBar = navcon.navigationBar
                
                //add nav bar title
                self.navigationController?.title = self.title
                let titleAttributes = [
                    NSForegroundColorAttributeName: UIColor.white,
                    NSFontAttributeName: UIFont(name: "Helvetica", size: 20)!
                ]
                UINavigationBar.appearance().titleTextAttributes = titleAttributes
                
                
                //color nav bar
                navBar.barTintColor = CustomColor.brandGreen
                navBar.tintColor = UIColor.white
                
                //create menu button in navbar with pan recognizer
                let menuButton = UIBarButtonItem(image: #imageLiteral(resourceName: "menu"), style: .plain, target: self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)))
                navigationItem.leftBarButtonItem = menuButton
                self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            }
        }
    }
    
    /**
     Parse JSON data
     - param validJSONObject: takes the result from FBSDK Graph request
     - returns: JSON dictionary
     */
    func parseJSON(validJSONObject: Any?) -> [String : Any]? {
        
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
