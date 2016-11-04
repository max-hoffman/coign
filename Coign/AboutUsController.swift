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
        "features text" : "We are currently testing the Beta version of Coign, which allows users to donate individual dollars to a handful of prominent charities. We do encourage users to share their donation messages on social media as a way to encourage others to take action in their own ways. We do not support donations larger than $1.50.",
        "team text": "The team at Coign includes two recent college graduates. We hope to grow Coign to a point where we can work full-time trying to integrate microdonation into society in a way that benefits both donators and their communities. We do have day jobs currently, and we'd like to enourage users who have advice and/or criticism to contact us and help improve the app.",
        "opportunities text": "Ambitious and talented students with heavy technical backgrounds, who lack risk-aversion, and who are interested in cofounding a startup are welcome to contact our team for more information.",
        ]
    
    @IBAction func viewSelected(sender: UIButton) {
        if let index = aboutButtons.index(of: sender) {
            if index == 4 {
                let faqStoryboard = UIStoryboard.init(name: Storyboard.Settings.rawValue, bundle: nil)
                let faqVC = faqStoryboard.instantiateViewController(withIdentifier: ViewController.FAQ.rawValue) as! FAQController
                self.navigationController?.pushViewController(faqVC, animated: true)
            }
                
            
            //if the button's text is currently showing
            else if !self.textViews[index].isHidden {
                expandViewToHideDetail(index: index)
            }
            else {
                collapseViewToShowDetail(index: index)
            }
        }
    }
    
    private func collapseViewToShowDetail(index: Array<UIButton>.Index) {
        UIView.animate(withDuration: 0.3, animations: {
            
            //hide buttons
            self.aboutViews.forEach {
                $0.isHidden = true
            }
            
            //show only the selected button and text
            self.textViews[index].isHidden = false
            self.aboutViews[index].isHidden = false
        })

    }
    
    private func expandViewToHideDetail(index: Array<UIButton>.Index) {
        //hide text, show buttons
        self.textViews[index].isHidden = true
        UIView.animate(withDuration: 0.3, animations: {
            self.aboutViews.forEach {
                $0.isHidden = false
            }
        })
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
