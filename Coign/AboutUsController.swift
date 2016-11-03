//
//  AboutUsController.swift
//  Coign
//
//  Created by Maximilian Hoffman on 9/11/16.
//  Copyright © 2016 The Maxes. All rights reserved.
//

import UIKit

class AboutUsController: UIViewController {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    @IBOutlet var aboutViews: [UIView]!
    
    @IBOutlet var aboutButtons: [UIButton]!

    @IBAction func viewSelected(sender: UIButton) {
        if let index = aboutButtons.index(of: sender) {
            
            UIView.animate(withDuration: 0.3, animations: {
                
                if self.aboutViews[0].isHidden || self.aboutViews[1].isHidden {
                    self.aboutViews.forEach {
                        $0.isHidden = false
//                        ($0.viewWithTag(1) as! UILabel).text = ""
                    }
                    self.aboutButtons.forEach {
                        $0.isHidden = false
                    }
                }
                else {
                    self.aboutViews.forEach {
                        $0.isHidden = true
                    }
                    self.aboutButtons.forEach {
                        $0.isHidden = true
                    }
                    self.aboutViews[index].isHidden = false
                    self.aboutButtons[index].isHidden = false
//                    (self.aboutViews[index].viewWithTag(1) as! UILabel).text = "practice"
                }

            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //nav bar for reveal view controller
        connectRevealVC()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
}
