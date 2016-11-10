//
//  TabController.swift
//  Coign
//
//  Created by Maximilian Hoffman on 11/2/16.
//  Copyright © 2016 Exlent Studios. All rights reserved.
//

import UIKit

class TabController: UITabBarController {

    //this is used to tab between different controllers in the tab view
    var segueDestinationIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //route to the correct tab view controller
        self.selectedIndex = segueDestinationIndex
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
