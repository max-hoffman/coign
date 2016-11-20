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
    
    //MARK: - Constants
    let POST_CELL_IDENTIFIER = "post cell"
    let HEADER_CELL_IDENTIFIER = "header cell"
    let FOOTER_CELL_IDENTIFIER = "footer cell"
    
    //MARK: - User setup properties and outlets
    var blurView: UIVisualEffectView? = nil
    var blurEffect: UIVisualEffect? = nil
    var segmentedControl: UISegmentedControl? = nil
    var recentPosts: [Post]? {
        didSet {
            DispatchQueue.main.async{
                self.tableView.reloadData()
            }
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
       //        let postArray = jsonPostArray.map {parseJSON(validJSONObject: $0)}
//        print(postArray)
        
        //nav bar for reveal view controller
        connectRevealVC()
        
        //load recent posts
        FirTree.queryRecentPosts() { postData in
            self.recentPosts = postData
        }
        
        //make ourselves the tableview delegate
        tableView.delegate = self
        
        // User setup delegation
        emailField.delegate = self
        phoneField.delegate = self
        nameField.delegate = self
        charityPreferencePicker.delegate = self
        charityPreferencePicker.dataSource = self
        tableView.backgroundView = UIImageView(image: UIImage(named: "coign_background_02"))
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        //home page loading logic, automatically calls user setup popover if the last date was set to "new user"
        checkLastLoginDate()
        
        //load recent posts
        FirTree.queryRecentPosts() { postData in
            self.recentPosts = postData
        }

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        
        if recentPosts != nil {
                return recentPosts!.count
            }
            else {return 1}
    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
//        if recentPosts != nil {
//            return recentPosts!.count
//        }
//        else {return 1}
        return 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(
            withIdentifier: POST_CELL_IDENTIFIER, for: indexPath) as? PostCell,
            let post = recentPosts?[indexPath.section] {
            
            if let donor = post.donor, let charity = post.charity {
                cell.header.text = "\(donor) → \(charity)"
            }
            
            if let time = post.timeStamp {
            cell.timeStamp.text = Double(time).formatMillisecondsToCoherentTime
            }
            
            //if let message = post.message {
                cell.postBody.text = post.message
            //}
            
            if let recipient = post.recipient?.lowercased().removeWhitespace() {
                if recipient != "" {
                    cell.recipientLabel.text = "@ \(recipient):"
                    cell.recipientLabel.textColor = UIColor.blue
                }
                else {
                    cell.recipientLabel.isHidden = true
                }
            }
            
            if let userID = post.donorUID {
                FirTree.returnImage(userID: userID, completionHandler: { (image) in
                    cell.picture?.image = image
                })
            }

            return cell
        }
        else {
            return UITableViewCell()
        }
        

    }
    
    /* Make the cell height dynamic based on the amount of "answer" text. It was also necessary to relax the vertical compression of the dynamic cell in the storyboard. */
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    //MARK: - Header methods
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0, let  headerCell = tableView.dequeueReusableCell(withIdentifier: HEADER_CELL_IDENTIFIER) as? HeaderCell {
                segmentedControl = headerCell.segmentedControl
                return headerCell
        }
        else { return tableView.dequeueReusableCell(withIdentifier: FOOTER_CELL_IDENTIFIER) as? FooterCell}
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 60
        }
        else { return 15 }
    }
    
    @IBAction func indexChanged(sender: UISegmentedControl) {
        if sender == segmentedControl {
            if let index = segmentedControl?.selectedSegmentIndex {
                switch index {
                    case 0:
                        print("recent selected")
                    //show popular view
                    case 1:
                        print("local selected")
                    //show history view
                    case 3:
                        print("friends selected")
                    default:
                        break;
                }
            }
        }
    }
    
    //MARK: Footer methods
    
//    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        if let footerCell = tableView.dequeueReusableCell(withIdentifier: FOOTER_CELL_IDENTIFIER) as? FooterCell {
//            return footerCell
//        }
//        else {
//            return nil
//        }
////        return tableView.dequeueReusableCell(withIdentifier: FOOTER_CELL_IDENTIFIER) as? FooterCell
//        
//    }
//    
//    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return CGFloat(10)
//    }
//    
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
