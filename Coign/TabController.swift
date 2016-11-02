//
//  TabController.swift
//  Coign
//
//  Created by Maximilian Hoffman on 11/2/16.
//  Copyright © 2016 Exlent Studios. All rights reserved.
//

import UIKit

class TabController: UITabBarController {

    var segueDestinationIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.selectedIndex = segueDestinationIndex
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
