//
//  ViewController.swift
//  Coign
//
//  Created by Maximilian Hoffman on 9/3/16.
//  Copyright © 2016 MaxMax. All rights reserved.
//

import UIKit

class LoginController: UIViewController {

    //MARK: - Stand-in for facebook login
    @IBAction func loginButtonPressed(sender: UIButton) {
        let storyboard = UIStoryboard(name: "MainApp", bundle: nil)
        let controller  = storyboard.instantiateInitialViewController()!
        self.presentViewController(controller, animated: true, completion: nil)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    

}

