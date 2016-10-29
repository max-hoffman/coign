//
//  SettingsController.swift
//  Coign
//
//  Created by Maximilian Hoffman on 9/11/16.
//  Copyright © 2016 The Maxes. All rights reserved.
//

import UIKit

class SettingsController: UITableViewController {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    struct Settings {
        enum Changeable: String {
            case name = "name cell"
            case birthday = "birthday cell"
            case email = "email cell"
            case phone = "phone cell"
        }
        enum Static: String {
            case faq = "faq cell"
            case feedback = "feedback cell"
            case policy = "policy cell"
            case terms = "terms cell"
            case attributions = "attributions cell"
        }
        enum Actionable: String {
            case permissions = "permission cell"
            case logout = "log out cell"
            case charityDefault = "charity default cell"
        }
    }
    
    private func changeableSetting(setting: String) -> Bool {
        return Settings.Changeable.init(rawValue: setting) != nil
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cellIdentifier = tableView.cellForRow(at: indexPath)?.reuseIdentifier
            else{
                print("cell identifier does not exist")
                return
        }
        
        //deep link to phone settings
        if cellIdentifier == Settings.Actionable.permissions.rawValue {
            if let appSettings = URL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.openURL(appSettings as URL)
            }
        }
            
        //log out of current user
        else if cellIdentifier == Settings.Actionable.logout.rawValue {
            //logout of application
        }
        
        //show picker view; default charity selection
        else if cellIdentifier == Settings.Actionable.charityDefault.rawValue {
            performSegue(withIdentifier: "show charirty picker view", sender: self)
        }
            
        //show setting detail page, can update account info
        else if changeableSetting(setting: cellIdentifier) {
            performSegue(withIdentifier: "show setting detail", sender: indexPath)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
     
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailVC = segue.destination as? SettingDetailController {
            if let index = sender as? IndexPath {
                let label = self.tableView.cellForRow(at: index)?.contentView.viewWithTag(1) as? UILabel
                if let name = label?.text {
                    detailVC.propertyName = name
                    detailVC.title = "Update \(name)"
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        connectRevealVC()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
}
