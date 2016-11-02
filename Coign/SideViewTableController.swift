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
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print(segue.destination)
        print(segue.identifier)
        if let tabVC = segue.destination as? TabController, let  identifier = segue.identifier {
            print(identifier)
            switch identifier {
                case "home segue": tabVC.segueDestinationIndex = 0
                case "donate segue": tabVC.segueDestinationIndex = 1
                case "profile segue": tabVC.segueDestinationIndex = 2
                default: print("unidentifiable segue name")
            }
            
        }
    }
}
