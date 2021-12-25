//
//  ProductCardCollectionViewCell.swift
//  WhatsDown
//
//  Created by Seun Oyeniyi on 12/24/21.
//  Copyright © 2021 Phuck Brand. All rights reserved.
//

import UIKit

protocol ProductCardDelegate {
    func updateWishlist(product_id: String, action: String)
}

class ProductCardCollectionViewCell: UICollectionViewCell {
    
    var cardDelegate: ProductCardDelegate?
    
    @IBOutlet var productImage: UIImageView!
    @IBOutlet var productTitle: UILabel!
    @IBOutlet var productPrice: UILabel!
    @IBOutlet var wishListBtn: WishListButton!
    
    var cartNotification: UILabel!
    
    var productID: String!
    var hasWishList: Bool = false
    var parentView: UIView!
    
    let userSession = UserSession()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        if (hasWishList) {
            wishListBtn.setImage(UIImage(named: "icons8_heart_outline_1"), for: .normal)
        } else {
            wishListBtn.setImage(UIImage(named: "icons8_heart_outline"), for: .normal)
        }
    }
    @IBAction func wishListBtnTapped(_ sender: WishListButton) {
        if (!userSession.logged()) {
            parentView.makeToast("Please login first!")
            return
        }
        if (hasWishList) {
            self.cardDelegate?.updateWishlist(product_id: productID, action: "remove")
            hasWishList = false
            wishListBtn.setImage(UIImage(named: "icons8_heart_outline"), for: .normal)
        } else {
            self.cardDelegate?.updateWishlist(product_id: productID, action: "add")
            hasWishList = true
            wishListBtn.setImage(UIImage(named: "icons8_heart_outline_1"), for: .normal)
        }
    }
    
}
