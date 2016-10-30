//
//  SettingDetailCell.swift
//  Coign
//
//  Created by Maximilian Hoffman on 10/27/16.
//  Copyright © 2016 Exlent Studios. All rights reserved.
//

import UIKit

class SettingDetailCell: UITableViewCell {

    @IBOutlet weak var property: UILabel!
    @IBOutlet weak var propertyTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
        propertyTextField.becomeFirstResponder()
    }
}
