//
//  SecondViewController.swift
//  Phuck Brand
//
//  Created by Seun Oyeniyi on 11/1/21.
//  Copyright © 2021 Phuck Brand. All rights reserved.
//

import UIKit
import Alamofire
import Toast_Swift
import SwiftyJSON



class MainCategoriesViewController: UIViewController {
    
    
    @IBOutlet var topCartBtn: UIBarButtonItem!
    
    let userSession = UserSession()
    
    
    var cartNotification: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setTabBarBorder()
        
        setupCartNotification()
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.userSession.reload()
        self.updateCartNotification()
    }
    
    @objc func cartMenuTapped(_ sender: UIButton) {
        self.tabsDelegate.cartMenuTapped()
    }
    
    func setupCartNotification() {
        let filterBtn = UIButton(type: .system)
        filterBtn.frame = CGRect.init(x: 0, y: 0, width: 30, height: 30)
        filterBtn.setImage(UIImage(named: "icons8_shopping_cart")?.withRenderingMode(.alwaysTemplate), for: .normal)
        filterBtn.tintColor = UIColor.black
        filterBtn.addTarget(self, action: #selector(cartMenuTapped(_:)), for: .touchUpInside)
        
        cartNotification = UILabel.init(frame: CGRect.init(x: 20, y: 2, width: 15, height: 15))
        cartNotification.backgroundColor = UIColor.red
        cartNotification.clipsToBounds = true
        cartNotification.layer.cornerRadius = 7
        cartNotification.textColor = UIColor.white
        cartNotification.font = cartNotification.font.withSize(10)
        cartNotification.textAlignment = .center
        cartNotification.text = "0"
        filterBtn.addSubview(cartNotification)
        topCartBtn.customView = filterBtn
        
        cartNotification.isHidden = true //hidden by default
        
        //update cartNofication from server
        updateCartNotification()
    }
    
    func updateCartNotification() {
        let url = Site.init().CART + userSession.ID
        
        Alamofire.request(url).responseJSON { (response) -> Void in
            //check if the result has a value
            if let json_result = response.result.value {
                let json = JSON(json_result)
                if (json["contents_count"].intValue > 0) {
                    self.cartNotification.text = json["contents_count"].stringValue
                    self.cartNotification.isHidden = false
                } else {
                    self.cartNotification.isHidden = true
                }
            }
        }
    }
    
    
}



