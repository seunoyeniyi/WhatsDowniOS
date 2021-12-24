//
//  OrdersTableViewCell.swift
//  Phuck Brand
//
//  Created by Seun Oyeniyi on 12/20/21.
//  Copyright © 2021 Phuck Brand. All rights reserved.
//

import UIKit

class OrdersTableViewCell: UITableViewCell {

    @IBOutlet var orderContainer: UIView!
    @IBOutlet var orderID: UILabel!
    @IBOutlet var orderDate: UILabel!
    @IBOutlet var orderPaymentMethod: UILabel!
    @IBOutlet var orderStatusImg: UIImageView!
    @IBOutlet var orderTotalPrice: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        orderContainer.layer.cornerRadius = 5
        orderContainer.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
