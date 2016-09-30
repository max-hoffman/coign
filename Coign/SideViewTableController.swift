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
            
            //give button permission to logout of facebook
            let facebookLogin = FBSDKLoginManager()
            
            //logout of firebase/facebook/userdefualts
            facebookLogin.logOut()
            try! FIRAuth.auth()!.signOut()
            FBSDKAccessToken.setCurrent(nil)
            FBSDKProfile.setCurrent(nil)
            
            //clear user defaults
            
            //segue to login screen
            let storyboard = UIStoryboard(name: "Login", bundle: nil)
            let controller  = storyboard.instantiateInitialViewController()!
            self.present(controller, animated: true, completion: nil)
        }
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
