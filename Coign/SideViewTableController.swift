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

class SideViewTableController: UITableViewController {

    @IBOutlet weak var logoutButton: UITableViewCell!
    
    //logout, return to login screen
    //func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
        //logout
        //try! FIRAuth.auth()?.signOut()
        
        //dismiss modal
        //self.dismiss(animated: true, completion: nil)
        
        //segue to login screen
        //let storyboard = UIStoryboard(name: "Login", bundle: nil)
        //let controller  = storyboard.instantiateInitialViewController()!
        //self.present(controller, animated: true, completion: nil)
    //}
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 1 && indexPath.row == 1){
            //logout
            try! FIRAuth.auth()!.signOut()
            print("should have logged out")
            
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
