//
//  CustomUI.swift
//  SkyeCommerce
//
//  Created by Seun Oyeniyi on 12/23/21.
//  Copyright © 2021 Phuck Brand. All rights reserved.
//

import UIKit



@IBDesignable
class StyleButton: UIButton {
    @IBInspectable var cornerRadius: CGFloat = 4.0 {
        didSet {
            setupView()
        }
    }
    override func awakeFromNib() {
        setupView()
    }
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupView()
    }
    func setupView() {
        self.styleIt()
        self.layer.cornerRadius = cornerRadius
    }
}


