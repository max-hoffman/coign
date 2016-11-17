//
//  PostCell.swift
//  Coign
//
//  Created by Maximilian Hoffman on 11/17/16.
//  Copyright © 2016 Exlent Studios. All rights reserved.
//

import UIKit

class PostCell: UITableViewCell {
    
    //MARK: - Outlets
    
    @IBOutlet weak var header: UILabel!
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var postBody: UILabel!
    
    
    //MARK: - Superclass methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
