//
//  SettingDetailController.swift
//  Coign
//
//  Created by Maximilian Hoffman on 10/27/16.
//  Copyright © 2016 Exlent Studios. All rights reserved.
//

import Foundation

class SettingDetailController: UITableViewController {
    
    //properties
    var propertyName: String? = nil
    var propertyValue: String? = nil
    
    //table view methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? SettingDetailCell
        cell?.property.text = propertyName
        cell?.propertyTextField.text = propertyValue
        return cell ?? UITableViewCell()
    }
    
    //superclass methods
    override func viewDidLoad() {
        super.viewDidLoad()
        return
    }
}
