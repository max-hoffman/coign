//
//  ProfileController.swift
//  Coign
//
//  Created by Maximilian Hoffman on 9/11/16.
//  Copyright © 2016 The Maxes. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class ProfileController: UIViewController {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    @IBOutlet weak var picture: UIImageView! {
        didSet {
            picture.layer.cornerRadius = picture.frame.width/4.0
        }
    }
    @IBOutlet weak var name: UILabel!
    
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
    
//    private func didSetDonationLabel() {
//        if let incomingText = incomingDonationsLabel.text,
//            let outgoingText = outgoigDonationsLabel.text {
//            if let incomingValue = Int(incomingText),
//                let outgoingValue = Int(outgoingText) {
//                networkGraphs[0].scale = CGFloat(incomingValue/(incomingValue + outgoingValue))
//                networkGraphs[1].scale = CGFloat(outgoingValue/(incomingValue + outgoingValue))
//                totalDonationsLabel.text = String(incomingValue + outgoingValue)
//            }
//        }
//    }
    
    private func prepareUserLabels() {
        self.name.text = UserDefaults.standard.object(forKey: FirTree.UserParameter.Name.rawValue) as? String ?? "name error"
    }
    
    @IBOutlet weak var totalDonationsLabel: UILabel!
    
    // MARK: - Navigation
    
    @IBOutlet var profileNavigation: [UIView]!
    
    func prepareProfileNavigation() {
        profileNavigation.forEach {
            let gesture = UITapGestureRecognizer(target: self, action: #selector(triggerSegue(_:)))
            $0.addGestureRecognizer(gesture)
        }
    }
    
    func triggerSegue(_ sender: UITapGestureRecognizer) {
        if sender.view?.tag == 2 {
            //TODO: pop support MVC
        }
        self.performSegue(withIdentifier: "profile detail segue", sender: sender.view)
    }
    

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailVC = segue.destination as? ProfileDetailController,
        let view = sender as? UIView  {
            switch view.tag {
                case 0:  detailVC.viewType = "notifications"
                case 1: detailVC.viewType = "coigns"
                default: print("unidentified segue")
            }
        }
    }

    //MARK: - Superclass methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //update the labels with user data
        prepareUserLabels()
        
        //add tap gesture recognizers to the navigation views
        prepareProfileNavigation()
        
        
        //load user image
        FirTree.returnCurrentUserImage { (image) in
            self.picture.image = image
        }
        //nav bar for reveal view controller
        connectRevealVC()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
