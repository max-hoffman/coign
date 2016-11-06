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
    }
    @IBAction func setDefaultButton(_ sender: UIButton) {
    }
    
    var name: String? = nil
    var url: URL? = nil
    var mission: String? = nil
    var rating: Int? = nil
    var category: String? = nil
    
    
    
    private func setOutlets() {
        nameLabel.text = name
        missionLabel.text = mission
        categoryLabel.text = category
        missionLabel.text = mission
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
