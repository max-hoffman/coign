//
//  CharityDetailController.swift
//  Coign
//
//  Created by Maximilian Hoffman on 11/5/16.
//  Copyright © 2016 Exlent Studios. All rights reserved.
//

import UIKit

class CharityDetailController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var ratingImage: UIImageView!
    
    @IBOutlet weak var missionLabel: UILabel!
    
    @IBOutlet weak var categoryLabel: UILabel!
    
    @IBAction func showMoreInfoButton(_ sender: UIButton) {
        if let url = URL(string: self.url!) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:])
            } else {
                // Fallback on earlier versions
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    @IBOutlet weak var makeDefaultButton: UIButton!
    
    @IBAction func updateDefault(_ sender: UIButton) {
        UserDefaults.standard.set(name, forKey: FirTree.UserParameter.Charity.rawValue)
            makeDefaultButton.backgroundColor = UIColor.lightGray
            makeDefaultButton.isEnabled = false
    }
    
    var name: String? = nil
    var url: String? = nil
    var mission: String? = nil
    var rating: Int? = nil
    var category: String? = nil
    var currrentDefault: String {
        return UserDefaults.standard.object(forKey: FirTree.UserParameter.Charity.rawValue) as! String
    }
    
    private func setOutlets() {
        nameLabel.text = name
        missionLabel.text = mission
        categoryLabel.text = category
        missionLabel.text = mission
        if currrentDefault == name {
            makeDefaultButton.backgroundColor = UIColor.lightGray
            makeDefaultButton.isEnabled = false
        }
        makeDefaultButton.setTitle("Your default", for: .disabled)
    }
    
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

  
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
