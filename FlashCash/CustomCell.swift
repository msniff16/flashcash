//
//  CustomCell.swift
//  FlashCash
//
//  Created by Julius Danek on 10/24/15.
//  Copyright © 2015 FlashCash. All rights reserved.
//

import UIKit
import Braintree

class CustomCell: UITableViewCell {
    
    @IBOutlet weak var cardHint: BTUICardHint!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
