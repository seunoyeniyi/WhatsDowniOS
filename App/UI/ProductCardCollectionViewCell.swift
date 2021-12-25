//
//  ProductCardCollectionViewCell.swift
//  WhatsDown
//
//  Created by Seun Oyeniyi on 12/24/21.
//  Copyright © 2021 Phuck Brand. All rights reserved.
//

import UIKit

class ProductCardCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var productImage: UIImageView!
    @IBOutlet var productTitle: UILabel!
    @IBOutlet var productPrice: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
