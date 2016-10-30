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
    
    @IBOutlet weak var nameValue: UILabel!
    @IBOutlet weak var birthdayValue: UILabel!
    @IBOutlet weak var phoneValue: UILabel!
    @IBOutlet weak var emailValue: UILabel!
    @IBOutlet weak var charityValue: UILabel!
    
    
    struct Settings {
        enum Changeable: String {
            case Name = "name"
            case Birthday = "birthday"
            case Email = "email"
            case Phone = "phone number"
        }
        enum Static: String {
            case Faq = "faq cell"
            case Feedback = "feedback cell"
            case Policy = "policy cell"
            case Terms = "terms cell"
            case Attributions = "attributions cell"
        }
        enum Actionable: String {
            case Permissions = "permissions cell"
            case Logout = "log out cell"
            case CharityDefault = "charity preference"
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
        if cellIdentifier == Settings.Actionable.Permissions.rawValue {
            if let appSettings = URL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.openURL(appSettings as URL)
            }
        }
            
        //log out of current user
        else if cellIdentifier == Settings.Actionable.Logout.rawValue {
            //logout of application
        }
        
        //show picker view; default charity selection
        else if cellIdentifier == Settings.Actionable.CharityDefault.rawValue {
            performSegue(withIdentifier: "show charity picker", sender: nil)
        }
        
        //MARK: - Need to be able to verify phone number
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
                    let key = tableView.cellForRow(at: index)?.reuseIdentifier
                    detailVC.propertyValue = UserDefaults.standard.string(forKey: key!)
                }
            }
        }
    }
    
    private func updateUserSettingsValues() {
        nameValue.text = UserDefaults.standard.string(forKey: FirTree.UserParameter.Name.rawValue)
        birthdayValue.text = UserDefaults.standard.string(forKey: FirTree.UserParameter.Birthday.rawValue)
        emailValue.text = UserDefaults.standard.string(forKey: FirTree.UserParameter.Email.rawValue)
        phoneValue.text = UserDefaults.standard.string(forKey: FirTree.UserParameter.Phone.rawValue)
        charityValue.text = UserDefaults.standard.string(forKey: FirTree.UserParameter.Charity.rawValue)
        print(charityValue.text ?? nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        connectRevealVC()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateUserSettingsValues()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
}
