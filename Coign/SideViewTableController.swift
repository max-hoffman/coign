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
 
    enum Segue: String {
        case Home = "home segue"
        case Donate = "donate segue"
        case Profile = "profile segue"
    }
    
    enum DestinationIndex: Int {
        case Home = 0, Donation, Profile
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let tabVC = segue.destination as? TabController, let  identifier = segue.identifier {

            switch identifier {
                case Segue.Home.rawValue: tabVC.segueDestinationIndex = DestinationIndex.Home.rawValue
                case Segue.Donate.rawValue: tabVC.segueDestinationIndex = DestinationIndex.Donation.rawValue
                case Segue.Profile.rawValue: tabVC.segueDestinationIndex = DestinationIndex.Profile.rawValue
                default: print("unidentifiable segue name")
            }
        }
    }
}
