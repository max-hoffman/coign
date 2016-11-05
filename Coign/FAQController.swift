//
//  FAQController.swift
//  Coign
//
//  Created by Maximilian Hoffman on 11/3/16.
//  Copyright © 2016 Exlent Studios. All rights reserved.
//

import UIKit

class FAQController: UITableViewController {
    
    var questions: [String]? = nil
    var answers: [String]? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        readPropertyList()
    
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return questions?.count ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "faq cell", for: indexPath) as! FAQCell
        
        cell.question.text = questions?[indexPath.row]
        cell.answer.text = answers?[indexPath.row]

        return cell
    }
    
    private func readPropertyList(){
        
        guard let path = Bundle.main.path(forResource: "FAQ", ofType: "plist"),
            let faqData = NSDictionary(contentsOfFile: path) as?
                Dictionary<String, Any>
        else {
            print("error parsing FAQ plist data")
            return
        }
        
        self.questions = faqData["Questions"] as? [String]
        self.answers = faqData["Answers"] as? [String]
    }
    


}
