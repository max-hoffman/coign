//
//  CharityInfoController.swift
//  Coign
//
//  Created by Maximilian Hoffman on 11/5/16.
//  Copyright © 2016 Exlent Studios. All rights reserved.
//

import UIKit

class CharityInfoController: UITableViewController {

    //MARK: - Properties
    var charityData: Dictionary<String, Any>? {
        if let path = Bundle.main.path(forResource: "CharityInfo", ofType: "plist") {
            return NSDictionary(contentsOfFile: path) as? Dictionary<String, Any>
        } else {
            return nil
        }
    }
    
    //MARK: - Tableview methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "show charity category segue", sender: tableView.cellForRow(at: indexPath))
    }
    
    // MARK: - Navigation
    
    /* 
     Open the selected charity category, and pass that information into the next viewcontroller.
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let categoryVC = segue.destination as? CharityCategoryController {
            if let category = (sender as? UITableViewCell)?.textLabel?.text {
                categoryVC.category = category
                categoryVC.title = category
                categoryVC.charityCategoryData = charityData?[category] as! Dictionary<String, Any>?
            }
        }
    }
    
    //MARK: - Superclass methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        connectRevealVC()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
