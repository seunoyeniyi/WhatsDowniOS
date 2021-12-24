//
//  AttributeTableViewCell.swift
//  Phuck Brand
//
//  Created by Seun Oyeniyi on 11/25/21.
//  Copyright © 2021 Phuck Brand. All rights reserved.
//

import UIKit
import iOSDropDown

protocol AttributeSelect {
    func attributeSelected(name: String, value: String)
}
class AttributeTableViewCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var dropDown: DropDown!
    
    var attributeDelegate: AttributeSelect?
    
    var attributeName: String!
    var options: Array<Dictionary<String, String>> = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        dropDown.attributedPlaceholder = NSAttributedString(
            string: "Select Option",
            attributes: [NSAttributedStringKey.foregroundColor: UIColor.black]
        )

        dropDown.didSelect{(selectedText, index, id) in
            self.attributeDelegate?.attributeSelected(name: self.attributeName, value: self.options[index]["name"] ?? "")
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

