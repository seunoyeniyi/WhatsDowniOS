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
        //back to double
        let toDouble = Double(String(format: "%.2f", priceDouble))
        
        return (toDouble?.formattedWithSeparator)!
    }
    
    public static func format(price: Double) -> String {
        //back to double
        let toDouble = Double(String(format: "%.2f", price))
        
        return (toDouble?.formattedWithSeparator)!
    }
}
