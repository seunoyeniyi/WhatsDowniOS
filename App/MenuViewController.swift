//
//  MenuViewController.swift
//  Phuck Brand
//
//  Created by Seun Oyeniyi on 12/1/21.
//  Copyright © 2021 Phuck Brand. All rights reserved.
//

import UIKit

enum MenuType: Int {
    case home
    case account
    case wishlist
    case orders
    case support
    case cancel
    case login
    case logout
}

class MenuViewController: UIViewController {
    
    let userSession = UserSession()
    
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var logoutBtn: UIButton!
    @IBOutlet var viewProfileBtn: UIButton!
    @IBOutlet var ordersNotificationLbl: CircleLabel!
    @IBOutlet var homeListView: ListView!
    @IBOutlet var accountListView: ListView!
    @IBOutlet var wishlistListView: ListView!
    @IBOutlet var ordersListView: ListView!
    @IBOutlet var supportListView: ListView!
    
    
    var delegate: ModalDelegate?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (userSession.logged()) {
            usernameLabel.text = userSession.username
            viewProfileBtn.setTitle("View Profile", for: .normal)
            logoutBtn.setTitle("Log Out", for: .normal)
        } else {
            usernameLabel.text = "Hi!"
            viewProfileBtn.setTitle("Login", for: .normal)
            logoutBtn.setTitle("Login", for: .normal)
        }
    
        if (Int(userSession.last_orders_count) ?? 0 > 0) {
            ordersNotificationLbl.isHidden = false
            ordersNotificationLbl.text = userSession.last_orders_count
        } else {
            ordersNotificationLbl.isHidden = true
            ordersNotificationLbl.text = "0"
        }
        
        
        homeListView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.homeTapped(_:))))
        accountListView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.accountTapped(_:))))
        wishlistListView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.wishListTapped(_:))))
        ordersListView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.ordersTapped(_:))))
        supportListView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.supportTapped(_:))))
        
        
    }
    
    @objc func homeTapped(_ sender: UITapGestureRecognizer? = nil) {
        dismiss(animated: true, completion: {
            if let delegate = self.delegate {
                delegate.menuItemsClicked(menuType: MenuType.home)
            }
        })
    }
    @objc func accountTapped(_ sender: UITapGestureRecognizer? = nil) {
       profileFunc()
    }
    @objc func wishListTapped(_ sender: UITapGestureRecognizer? = nil) {
        dismiss(animated: true, completion: {
            if let delegate = self.delegate {
                delegate.menuItemsClicked(menuType: MenuType.wishlist)
            }
        })
    }
    @objc func ordersTapped(_ sender: UITapGestureRecognizer? = nil) {
        dismiss(animated: true, completion: {
            if let delegate = self.delegate {
                delegate.menuItemsClicked(menuType: MenuType.orders)
            }
        })
    }
    @objc func supportTapped(_ sender: UITapGestureRecognizer? = nil) {
        dismiss(animated: true, completion: {
            if let delegate = self.delegate {
                    delegate.menuItemsClicked(menuType: MenuType.support)
                }
        })
    }
    
    
    @IBAction func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    func profileFunc() {
        dismiss(animated: true, completion: {
            if let delegate = self.delegate {
                if (self.userSession.logged()) {
                    delegate.menuItemsClicked(menuType: MenuType.account)
                } else {
                    delegate.menuItemsClicked(menuType: MenuType.login)
                }
            }
        })
    }
    @IBAction func viewProfileTapped(_ sender: Any) {
        profileFunc()
    }
    
    @IBAction func logoutTapped(_ sender: Any) {
        dismiss(animated: true, completion: {
            if let delegate = self.delegate {
                if (self.userSession.logged()) {
                    delegate.menuItemsClicked(menuType: MenuType.logout)
                } else {
                    delegate.menuItemsClicked(menuType: MenuType.login)
                }
                
            }
        })
    }
    
    func myDismiss() {
        self.dismiss(animated: true, completion: nil)
    }

}

