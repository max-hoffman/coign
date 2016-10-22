//
//  LogoutController.swift
//  Coign
//
//  Created by Maximilian Hoffman on 9/18/16.
//  Copyright © 2016 Exlent Studios. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FBSDKCoreKit
import FBSDKLoginKit

class SideViewTableController: UITableViewController {

    @IBOutlet weak var logoutButton: UITableViewCell!
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 1 && indexPath.row == 1){
            
            let logoutAlert = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: UIAlertControllerStyle.alert)
            logoutAlert.addAction(UIAlertAction(title: "Logout", style: .default, handler: {
                (action: UIAlertAction) -> Void in
                    self.logout()
            }))
            logoutAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {
                (action: UIAlertAction) -> Void in
                self.dismiss(animated: false, completion: nil)
            }))
            
            present(logoutAlert, animated: true, completion: nil)
               }
    }
    
    private func logout() {
        
        //logout of firebase/facebook
        FBSDKLoginManager().logOut()
        try! FIRAuth.auth()!.signOut()
        FBSDKAccessToken.setCurrent(nil)
        FBSDKProfile.setCurrent(nil)
        
        //clear defaults
        UserDefaults.standard.removeObject(forKey: "facebookID")
        UserDefaults.standard.removeObject(forKey: "name")
        UserDefaults.standard.removeObject(forKey: "pictureURL")
        UserDefaults.standard.removeObject(forKey: "most recent login date")
        
        //set login as the root VC
        let loginStoryboard = UIStoryboard(name: "Login", bundle: .main)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = loginStoryboard.instantiateInitialViewController()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
