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

    //need body views and texts
    @IBOutlet var textViews: [UIView]! {
        didSet {
            textViews.forEach {
                $0.isHidden = true
            }
        }
    }
    
    @IBOutlet var textLabels: [UILabel]! {
        didSet {
            textLabels.forEach {
                $0.text = labelDictionary[$0.text!] ?? "error loading text"
            }
        }
    }
    
    let labelDictionary = [
        "mission text" : "At Coign, we strive to make donation and personal finance simple, social and substantial. If you would like to incorporate microdonation in your life by helping communities, thanking friends or claiming coupons, then Coign puts you in a position to take action by helping others.",
        "features text" : "We are currently testing the Beta version of Coign, which allows users to donate individual dollars to a handful of prominent charities. We do encourage users to share their donation messages on social media as a way to encourage others to take action in their own small way. We do not support donations larger than $1.50.",
        "team text": "The team at Coign is currently two recent post-graduates. We hope to grow Coign to a point where we can work full-time on trying to integrate microdonation into society in a way that benefits donators, as well as local and national communities.",
        "opportunities text": "Ambitious and talented students who have heavy technical backgrounds, lack risk-aversion, and who are interested in coufounding a startup are welcome to contact our team for more information.",
        
        ]
    
    @IBAction func viewSelected(sender: UIButton) {
        if let index = aboutButtons.index(of: sender) {
            
            UIView.animate(withDuration: 0.3, animations: {
                
                if self.aboutViews[0].isHidden || self.aboutViews[1].isHidden {
                    self.aboutViews.forEach {
                        $0.isHidden = false
                    }
                    self.textViews[index].isHidden = true

                }
                else {
                    self.aboutViews.forEach {
                        $0.isHidden = true
                    }
                    self.textViews[index].isHidden = false
                    self.aboutViews[index].isHidden = false
                   

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
