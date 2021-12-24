//
//  CartTableViewCell.swift
//  Phuck Brand
//
//  Created by Seun Oyeniyi on 12/9/21.
//  Copyright © 2021 Phuck Brand. All rights reserved.
//

import UIKit

protocol CartTableDelegate {
    func quantityUpdated(productID: String, quantity: Int, index: Int)
}

class CartTableViewCell: UITableViewCell {
    
    var delegate: CartTableDelegate?
    var index: Int?
    var quantity: Int = 1
    var productID: String!
    
    @IBOutlet var productImage: UIImageView!
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var priceLbl: UILabel!
    @IBOutlet var decreaseBtn: UIButton!
    @IBOutlet var increaseBtn: UIButton!
    @IBOutlet var quantityLbl: UILabel!
    @IBOutlet var removeBtn: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func decreaseTapped(_ sender: UIButton) {
        if (quantity > 1) {
            quantity -= 1
        }
        quantityLbl.text = String(quantity)
        delegate?.quantityUpdated(productID: self.productID, quantity: quantity, index: self.index!)
    }
    @IBAction func increaseTapped(_ sender: UIButton) {
        quantity += 1
        quantityLbl.text = String(quantity)
        delegate?.quantityUpdated(productID: self.productID, quantity: quantity, index: self.index!)
    }
    @IBAction func removeTapped(_ sender: UIButton) {
        delegate?.quantityUpdated(productID: self.productID, quantity: 0, index: self.index!)
    }
    
    
}
