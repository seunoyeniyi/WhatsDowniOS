//
//  MenuTableViewCell.swift
//  Phuck Brand
//
//  Created by Seun Oyeniyi on 12/1/21.
//  Copyright © 2021 Phuck Brand. All rights reserved.
//

import UIKit

class MenuTableViewCell: UITableViewCell {
    @IBOutlet var imageIcon: UIImageView!
    @IBOutlet var titleLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
