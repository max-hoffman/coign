//
//  CharityCategoryController.swift
//  Coign
//
//  Created by Maximilian Hoffman on 11/5/16.
//  Copyright © 2016 Exlent Studios. All rights reserved.
//

import UIKit

class CharityCategoryController: UITableViewController {

    var category: String? = nil
    
    var charityCategoryData: Dictionary<String, Any>? = nil
    
    var name: [String]? {
        return charityCategoryData?["Name"] as! [String]?
    }
    
    var rating: [String]? {
        return charityCategoryData?["Rating"] as! [String]?
    }
    
    var mission: [String]? {
        return charityCategoryData?["Mission"] as! [String]?
    }
    
    var url: [String]? {
        return charityCategoryData?["URL"] as! [String]?
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return name?.count ?? 0
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "charity cell", for: indexPath)
        cell.textLabel?.text = name?[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "show charity detail segue", sender: indexPath.row)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailVC = segue.destination as? CharityDetailController {
            if let index = sender as? Int {
                detailVC.name = self.name?[index]
                detailVC.category = self.title
                detailVC.mission = self.mission?[index]
                detailVC.url = URL(fileURLWithPath: (self.url?[index])!)
            }
        }
    }
}
