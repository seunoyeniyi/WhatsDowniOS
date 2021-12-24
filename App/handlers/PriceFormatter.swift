//
//  PriceFormatter.swift
//  Phuck Brand
//
//  Created by Seun Oyeniyi on 12/9/21.
//  Copyright © 2021 Phuck Brand. All rights reserved.
//

import Foundation

class PriceFormatter {
    public static func format(price: String) -> String {
        let priceDouble: Double = Double(price)!
        return String(format: "%.2f", priceDouble)
    }
    
    public static func format(price: Double) -> String {
        return String(format: "%.2f", price)
    }
}
