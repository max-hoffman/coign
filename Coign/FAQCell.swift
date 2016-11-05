//
//  FAQCell.swift
//  Coign
//
//  Created by Maximilian Hoffman on 11/4/16.
//  Copyright © 2016 Exlent Studios. All rights reserved.
//

import UIKit

class FAQCell: UITableViewCell {

    @IBOutlet weak var answer: UILabel!
    @IBOutlet weak var question: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
