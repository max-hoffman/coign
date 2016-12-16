//
//  CharityDetailController.swift
//  Coign
//
//  Created by Maximilian Hoffman on 11/5/16.
//  Copyright © 2016 Exlent Studios. All rights reserved.
//

import UIKit

class CharityDetailController: UIViewController {

    //MARK: - Properties
    var name: String? = nil
    var url: String? = nil
    var mission: String? = nil
    var rating: Int? = nil
    var category: String? = nil
    var currrentDefault: String {
        return UserDefaults.standard.object(forKey: FirTree.UserParameter.Charity.rawValue) as! String
    }
    
    //MARK: - Outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingImage: UIImageView!
    @IBOutlet weak var missionLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var makeDefaultButton: UIButton!
    
    //MARK: - Buttons
    
    /* 
     Give the user a notification to check if they want to open the hyperlink in Safari.
     */
    @IBAction func showMoreInfoButton(_ sender: UIButton) {
        tryCharityHyperlink()
    }
    
    /* 
     Update the user's preset default charity. The button will be disabled and say that the default has been set. At the moment there can only be one "default charity" at any given time, although it would not be difficult to set several (make the value an array).
     */
    @IBAction func updateDefault(_ sender: UIButton) {
        if name != nil {
            UserDefaults.standard.set(name, forKey: FirTree.UserParameter.Charity.rawValue)
            FirTree.updateUser([FirTree.UserParameter.Charity.rawValue: name!])
            
            lockDefaultButton()
        }
    }
    
    //MARK: - Class methods
    
    /* 
     Takes the data passed during the segue and sets the proper view. If this is the user's defualt charity, this method handles that case.
     
     //TODO: The charity rating image is not set. Need to make photoshop images that we would set in here based on the "rating" property.
     */
    fileprivate func setOutlets() {
        nameLabel.text = name
        missionLabel.text = mission
        categoryLabel.text = category
        missionLabel.text = mission
        
        makeDefaultButton.setTitle("Your default", for: .disabled)
        makeDefaultButton.setTitleColor(UIColor.darkGray, for: .disabled)

        if currrentDefault == name {
            lockDefaultButton()
        }
    }
    
    fileprivate func lockDefaultButton() {
        makeDefaultButton.backgroundColor = .clear
        makeDefaultButton.layer.cornerRadius = 15
        makeDefaultButton.layer.borderWidth = 2
        makeDefaultButton.layer.borderColor = UIColor.lightGray.cgColor
        makeDefaultButton.isEnabled = false
    }
    
    /*
     This method is responsible for presenting the alert before a user exits the app to informational link of the charity's page.
     */
    fileprivate func tryCharityHyperlink() {
        let hyperlinkAlert = UIAlertController(title: "Hyperlink to \"\(name!)\" Details", message: "Exit Coign and open Safari?", preferredStyle: UIAlertControllerStyle.alert)
        hyperlinkAlert.addAction(UIAlertAction(title: "Open", style: .default, handler: {
            [weak weakSelf = self]
            (action: UIAlertAction) -> Void in
            
            weakSelf?.presentCharityHyperlink()
        }))
        hyperlinkAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (action: UIAlertAction) -> Void in
            self.dismiss(animated: true, completion: nil)
        }))
        
        present(hyperlinkAlert, animated: true, completion: nil)
    }
    
    /*
     This actually forwards the user to a webpage outside of the app.
     
     TODO: All of the links are the same outside of the last few integers, which represents the charity ID number. It would be a good idea to have the CharityInfo.plist contain the ID number, and the rest of the 90% of the link to just be a literal in this function.
    */
    fileprivate func presentCharityHyperlink() {
        if let url = URL(string: self.url!) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:])
            } else {
                // Fallback on earlier versions
                UIApplication.shared.openURL(url)
            }
        }
    }

    //MARK: - Superclass methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setOutlets()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
