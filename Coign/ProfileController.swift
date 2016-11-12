//
//  ProfileController.swift
//  Coign
//
//  Created by Maximilian Hoffman on 9/11/16.
//  Copyright © 2016 The Maxes. All rights reserved.
//

import UIKit

class ProfileController: UIViewController {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    
    @IBOutlet var networkGraphs: [NetworkGraph]!
    
    @IBOutlet weak var incomingDonationsLabel: UILabel! {
        didSet {
            //didSetDonationLabel()
        }
    }
    
    @IBOutlet weak var outgoigDonationsLabel: UILabel! {
        didSet {
            //didSetDonationLabel()
        }
    }
    
    private func didSetDonationLabel() {
        if let incomingText = incomingDonationsLabel.text,
            let outgoingText = outgoigDonationsLabel.text {
            if let incomingValue = Int(incomingText),
                let outgoingValue = Int(outgoingText) {
                networkGraphs[0].scale = CGFloat(incomingValue/(incomingValue + outgoingValue))
                networkGraphs[1].scale = CGFloat(outgoingValue/(incomingValue + outgoingValue))
                totalDonationsLabel.text = String(incomingValue + outgoingValue)
            }
        }
    }
    @IBOutlet weak var totalDonationsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareProfileNativation()
        
        //nav bar for reveal view controller
        connectRevealVC()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
   
    // MARK: - Navigation
    
    @IBOutlet var profileNavigation: [UIView]!
    
    func prepareProfileNativation() {


        profileNavigation.forEach {
            let gesture = UITapGestureRecognizer(target: self, action: #selector(triggerSegue(_:)))
            $0.addGestureRecognizer(gesture)
        }
    }
    
    func triggerSegue(_ sender: UITapGestureRecognizer) {
        self.performSegue(withIdentifier: "profile detail segue", sender: sender.view)
    }
    

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let view = sender as? UIView {
            print(view.tag)
        }
    }


}
