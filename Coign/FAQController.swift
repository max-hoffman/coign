//
//  FAQController.swift
//  Coign
//
//  Created by Maximilian Hoffman on 11/3/16.
//  Copyright © 2016 Exlent Studios. All rights reserved.
//

import UIKit

class FAQController: UITableViewController {
    
    //MARK: - Properties
    
    var faqData: Dictionary<String, Any>? {
        if let path = Bundle.main.path(forResource: "FAQ", ofType: "plist") {
            return NSDictionary(contentsOfFile: path) as? Dictionary<String, Any>
        } else {
            return nil
        }
    }
    
    var questions: [String]? {
        return faqData?["Questions"] as? [String]
    }
    
    var answers: [String]? {
        return faqData?["Answers"] as? [String]
    }
    
     // MARK: - Table view methods

    /* Make the cell height dynamic based on the amount of "answer" text. It was also necessary to relax the vertical compression of the dynamic cell in the storyboard. */
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    /* Only one section in FAQs */
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    /* Req tableview function; counts number of cells, which will always be the size of our plist array */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questions?.count ?? 0
    }

    /* Add questions and answers to the cells. The height is automatically dynamic already. */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //dequeue and format each cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "faq cell", for: indexPath) as! FAQCell
        cell.question.text = questions?[indexPath.row]
        cell.answer.text = answers?[indexPath.row]
        return cell
    }
    
    //MARK: - Superclass methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
