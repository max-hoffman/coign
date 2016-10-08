//
//  MainMenuController.swift
//  Coign
//
//  Created by Maximilian Hoffman on 9/11/16.
//  Copyright © 2016 The Maxes. All rights reserved.
//

import UIKit

class MainMenuController: UIViewController {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var userSetupPopover: UIView!
    
    override func viewDidLoad() {

        super.viewDidLoad()
        // Do view setup here.
        
        //MARK: this should be standardized so we're not duplicating code
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func presentUserSetupPopover() {
        print("attempted to present popover")
        navigationController?.setNavigationBarHidden(true, animated: true)
        //blur and vibrancy
        //let blurAndVirbrancyView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: UIBlurEffect(style: .dark)))
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blurView.frame = view.frame
        view.addSubview(blurView)
        
        //show popover
        self.view.addSubview(userSetupPopover)
        userSetupPopover.layer.cornerRadius = 5
        userSetupPopover.center = self.view.center
    }
    
    private func dismissUserPopover() {
        
    }
}
