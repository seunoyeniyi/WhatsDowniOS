//
//  OrderItemsTableViewCell.swift
//  Phuck Brand
//
//  Created by Seun Oyeniyi on 12/21/21.
//  Copyright © 2021 Phuck Brand. All rights reserved.
//

import UIKit

class OrderItemsTableViewCell: UITableViewCell {
    
    @IBOutlet var quantity: UILabel!
    @IBOutlet var title: UILabel!
    @IBOutlet var price: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
