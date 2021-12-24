//
//  MenuViewController.swift
//  Phuck Brand
//
//  Created by Seun Oyeniyi on 12/1/21.
//  Copyright © 2021 Phuck Brand. All rights reserved.
//

import UIKit

enum MenuType: Int {
    case login
    case wishlist
    case my_orders
    case pending_delivery
    case pending_payments
    case completed_orders
    case shipping_address
    case about_us
    case logout
}

class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let userSession = UserSession()
    
    @IBOutlet var usernameLabel: UILabel!
    
    
    var delegate: ModalDelegate?
    
    
    let menuLists: Array<Dictionary<String, String>> = [
        ["name": "Login", "image": "icons8_login"],
        ["name": "Wishlist", "image": "icons8_middle_finger_1"],
        ["name": "My Orders", "image": "icons8_product"],
        ["name": "Pending Delivery", "image": "icons8_data_pending"],
        ["name": "Pending Payments", "image": "icons8_payment_history"],
        ["name": "Completed Orders", "image": "icons8_task_completed"],
        ["name": "Shipping Address", "image": "icons8_address"],
        ["name": "About us", "image": "icons8_info"],
        ["name": "Logout", "image": "icons8_logout_rounded_left"],
        ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (userSession.logged()) {
            usernameLabel.text = userSession.username
        } else {
            usernameLabel.text = "Hi!"
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let menuType = MenuType(rawValue: indexPath.row) else { return }

        dismiss(animated: true, completion: {
            if let delegate = self.delegate {
                delegate.menuItemsClicked(menuType: menuType)
            }
        })
    }
    
    // MARK: - Table view data source
    
    
    //must tell the number of rows to display
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return menuLists.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            if userSession.logged()  { return 0 }
        }
        if indexPath.row == 8 {
            if !userSession.logged()  { return 0 }
        }
        
        return tableView.rowHeight
    }
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuTableCell", for: indexPath) as! MenuTableViewCell
        cell.titleLbl.text = menuLists[indexPath.row]["name"]
        cell.imageIcon.image = UIImage(named: menuLists[indexPath.row]["image"]!)
        
        return cell
    }
    
    func myDismiss() {
        dismiss(animated: true)
    }
  
    
}

