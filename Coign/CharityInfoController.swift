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
    
    var charityCategories: [String]? {
        if let path = Bundle.main.path(forResource: "CharityCategories", ofType: "plist") {
            return NSArray(contentsOfFile: path) as? [String]
        } else {
            return nil
        }
    }
    
    //MARK: - Tableview methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "show charity detail segue", sender: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let categoryName = charityCategories?[section], let categoryData = charityData?[categoryName] as? Dictionary<String, Any>, let nameArray = categoryData["Name"] as? [String] {
                return nameArray.count
        }
        else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "charity cell"), let categoryName = charityCategories?[indexPath.section], let categoryData = charityData?[categoryName] as? Dictionary<String, Any>, let nameArray = categoryData["Name"] as? [String] {
            cell.textLabel?.text = nameArray[indexPath.row]
            return cell
        }
        else {
            return UITableViewCell()
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
         //#warning Incomplete implementation, return the number of sections
        return charityCategories?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return charityCategories?[section]
    }
    // MARK: - Navigation
    
    /* 
     Open the selected charity category, and pass that information into the next viewcontroller.
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailVC = segue.destination as? CharityDetailController, let indexPath = sender as? IndexPath {
            if let categoryName = charityCategories?[indexPath.section], let categoryData = charityData?[categoryName] as? Dictionary<String, [Any]> {
                detailVC.name = categoryData["Name"]?[indexPath.row] as? String
                detailVC.mission = categoryData["Mission"]?[indexPath.row] as? String
                detailVC.url = categoryData["URL"]?[indexPath.row] as? String
                detailVC.rating = categoryData["Rating"]?[indexPath.row] as? Int
                detailVC.category = categoryName
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
