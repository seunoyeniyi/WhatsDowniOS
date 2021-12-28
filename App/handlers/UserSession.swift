//
//  UserSession.swift
//  Phuck Brand
//
//  Created by Seun Oyeniyi on 11/8/21.
//  Copyright © 2021 Phuck Brand. All rights reserved.
//

import UIKit

class UserSession: NSObject {
    var defaults = `UserDefaults`.standard
    
    var ID: String = "0"
    var username: String = ""
    var email: String = ""
    var last_orders_count = "0"
    var last_cart_count = "0"
    var date: Date = Date()
    
    override init() {
        if let default_id = defaults.object(forKey: "ID") {
            self.ID = String(describing: default_id)
        }
        if let default_username = defaults.object(forKey: "username") {
            self.username = default_username as! String
        }
        if let default_email = defaults.object(forKey: "email") {
            self.email = default_email as! String
        }
        if let default_date = defaults.object(forKey: "date") {
            self.date = default_date as! Date
        }
        if let default_orders_count = defaults.object(forKey: "last_orders_count") {
            self.last_orders_count = String(describing: default_orders_count)
        }
        if let default_cart_count = defaults.object(forKey: "last_cart_count") {
            self.last_cart_count = String(describing: default_cart_count)
        }
    }
    
    func createLoginSession(userID: String, xusername: String, xemail: String, logged: Bool) {
        self.ID = userID
        self.username = xusername
        self.email = xemail
        self.date = Date()
        
        defaults.set(userID, forKey: "ID")
        defaults.set(xusername, forKey: "username")
        defaults.set(xemail, forKey: "email")
        defaults.set(Date(), forKey: "date")
        defaults.set(logged, forKey: "logged")
        defaults.synchronize()
    }
    
    func getDetails() -> Dictionary<String, Any> {
        let data: [String: Any] = [
            "ID": defaults.object(forKey: "ID") ?? 0,
            "username": defaults.object(forKey: "username") ?? "",
            "email": defaults.object(forKey: "email") ?? "",
            "date": defaults.object(forKey: "date") ?? Date(),
            "logged": defaults.object(forKey: "logged") ?? false,
            "last_orders_count": defaults.object(forKey: "last_orders_count") ?? "0",
            "last_cart_count": defaults.object(forKey: "last_cart_count") ?? "0"
        ]
        return data
    }
    
    func reload() {
        defaults = `UserDefaults`.standard //re-fetch defaults
        
        self.ID = (defaults.object(forKey: "ID") ?? "0") as! String
        self.username = (defaults.object(forKey: "username") ?? "") as! String
        self.email = (defaults.object(forKey: "email") ?? "") as! String
        self.date = (defaults.object(forKey: "date") ?? Date()) as! Date
        self.last_orders_count = (defaults.object(forKey: "last_orders_count") ?? "0") as! String
        self.last_cart_count = (defaults.object(forKey: "last_cart_count") ?? "0") as! String
    }
    
    func update_last_orders_count(count: String) {
        defaults.set(count, forKey: "last_orders_count")
        defaults.synchronize()
        self.last_orders_count = count
    }
    func update_last_cart_count(count: String) {
        defaults.set(count, forKey: "last_cart_count")
        defaults.synchronize()
        self.last_cart_count = count
    }
    
    func add_wallet_address(address: String) {
        defaults.set(address, forKey: "wallet_address")
        defaults.synchronize()
    }
    func has_wallet_address() -> Bool {
        if let address = defaults.object(forKey: "wallet_address") {
            return ((address as! String).count > 0)
        } else {
            return false
        }
    }
    func get_wallet_address() -> String {
        if has_wallet_address() {
            return defaults.object(forKey: "wallet_address") as! String
        } else {
            return ""
        }
    }
    
    func set_last_play_chance(last: Date) {
        defaults.set(last, forKey: "last_play")
        defaults.synchronize()
    }
    func has_last_play_chance() -> Bool {
        if defaults.object(forKey: "last_play") is Date {
            return true
        } else {
            return false
        }
    }
    func get_last_play_chance() -> Date {
        if has_last_play_chance() {
            return defaults.object(forKey: "last_play") as! Date
        } else {
            return Date()
        }
    }
    
    
    func logged() -> Bool {
        if let logged = defaults.object(forKey: "logged") {
            return (logged as! Bool && ID != "0")
        } else {
            return false
        }
    }
    func logout() {
        //first option
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
        
        //second option
        let domain = Bundle.main.bundleIdentifier!
        defaults.removePersistentDomain(forName: domain)
        defaults.synchronize()
        
        self.reload()
    }
    
    
}
