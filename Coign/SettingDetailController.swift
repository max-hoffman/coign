//
//  SettingDetailController.swift
//  Coign
//
//  Created by Maximilian Hoffman on 10/27/16.
//  Copyright © 2016 Exlent Studios. All rights reserved.
//

import Foundation

class SettingDetailController: UITableViewController, UITextFieldDelegate {
    
    //properties
    var propertyName: String? = nil
    var propertyValue: String? = nil
    var cell: SettingDetailCell? = nil
    var defaultsKey: String? = nil
    
    //table view methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    /* Set the label and textfield data. The reason userdefaults is not called explicity is because this is a general setting page, usable by every single editable setting. The data is still being drawn from user defaults, however. */
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! SettingDetailCell?
        cell?.property.text = propertyName
        cell?.propertyTextField.text = propertyValue
        cell?.propertyTextField.delegate = self
        return cell ?? UITableViewCell()
    }
    
    //leave the page when we press return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        _ = navigationController?.popViewController(animated: true)
        textField.resignFirstResponder()
        return true
    }
        
    //superclass methods
    override func viewDidLoad() {
        super.viewDidLoad()
        return
    }
    
    /* Update the user settings in FirTree and Defaults when we leave the page, regardless of exit method. */
    override func viewWillDisappear(_ animated: Bool) {
        if let newValue = cell?.propertyTextField.text, defaultsKey != nil {
            let newSetting: [String: Any] = [defaultsKey! : newValue]
            FirTree.updateUser(newSetting)
            UserDefaults.standard.set(newValue, forKey: defaultsKey!)
        }
    }
}
