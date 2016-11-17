//
//  HomeMenuController.swift
//  Coign
//
//  Created by Maximilian Hoffman on 11/16/16.
//  Copyright © 2016 Exlent Studios. All rights reserved.
//

import UIKit

class HomeMenuController: UITableViewController {

    //MARK: Maybe move the popover outlets into a separate view controller, and then change the present popover segue accordingly. Make a xib file, then load nib into this controller? Might not be necessary
    
    //MARK: - User setup properties and outlets
    var blurView: UIVisualEffectView?
    var blurEffect: UIVisualEffect?
    var recentPosts: [[String: Any]]? {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    //UI outlets and actions
    @IBOutlet weak var userSetupPopover: UIView!
    @IBAction func dismissPopover(_ sender: UIButton) {
        storeUserInfo()
        dismissUserPopover()
    }
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var charityPreferencePicker: UIPickerView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    //MARK: - Superview and load functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: pull in an array of posts to load into the post cells
        FirTree.queryRecentPosts() { postData in
            self.recentPosts = postData
        }
//        let postArray = jsonPostArray.map {parseJSON(validJSONObject: $0)}
//        print(postArray)
        
        //nav bar for reveal view controller
        connectRevealVC()
        
        // User setup delegation
        emailField.delegate = self
        phoneField.delegate = self
        nameField.delegate = self
        charityPreferencePicker.delegate = self
        charityPreferencePicker.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        //home page loading logic, automatically calls user setup popover if the last date was set to "new user"
        checkLastLoginDate()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return recentPosts?.count ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "post cell", for: indexPath) as? PostCell, let post = recentPosts?[indexPath.row] {
            cell.header.text = post[FirTree.PostParameter.TimeStamp.rawValue] as? String
            cell.timeStamp.text = String (describing: post[FirTree.PostParameter.TimeStamp.rawValue] as? Int)
            cell.postBody.text = post[FirTree.PostParameter.Message.rawValue] as? String
            print("should fill cell")
            return cell
        }
        else {
            return UITableViewCell()
        }
        

    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
