//
//  ProfileHeaderCell.swift
//  Coign
//
//  Created by Maximilian Hoffman on 12/23/16.
//  Copyright © 2016 Exlent Studios. All rights reserved.
//

import UIKit

class ProfileHeaderCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView! {
        didSet {
            profileImage.layer.cornerRadius = profileImage.frame.width/2.0
        }
    }
    @IBOutlet weak var name: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
