//
//  PostsTableViewCell.swift
//  PikaChat
//
//  Created by Praveen Gowda I V on 7/25/16.
//  Copyright © 2016 Gowda I V, Praveen. All rights reserved.
//

import UIKit

class PostsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var postTitleLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    var postKey: String!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
