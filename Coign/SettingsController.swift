//
//  SettingsController.swift
//  Coign
//
//  Created by Maximilian Hoffman on 9/11/16.
//  Copyright © 2016 The Maxes. All rights reserved.
//

import UIKit

class SettingsController: UIViewController {

    @IBOutlet weak var menuButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        connectRevealVC()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
}
