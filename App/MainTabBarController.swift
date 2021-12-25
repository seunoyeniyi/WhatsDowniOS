//
//  MainTabBarController.swift
//  Phuck Brand
//
//  Created by Seun Oyeniyi on 12/18/21.
//  Copyright © 2021 Phuck Brand. All rights reserved.
//

import UIKit

protocol TabsDelegate {
    func menuTapped()
    func cartMenuTapped()
    func loginAction()
}

protocol ModalDelegate {
    func menuItemsClicked(menuType: MenuType)
}

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    @IBOutlet var theTabBar: UITabBar!
    
    let userSession = UserSession()
    
    let transition = SlideInTransition()
    var menuViewController: MenuViewController!
    let loginViewController = LoginViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        
        
        setupMenuController()
        
       
        
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        viewController.tabsDelegate = self
    }
    
    func login() {
        self.present(loginViewController, animated: true)
        //self.navigationController?.pushViewController(loginViewController, animated: true)
    }
    
    
    func setupMenuController() {
        transition.myDelegate = self
        self.modalPresentationStyle = .fullScreen
        menuViewController = storyboard?.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        menuViewController.modalPresentationStyle = .overCurrentContext
        menuViewController.transitioningDelegate = self
        menuViewController.delegate = self
    }
    
    
}

//allow all UIViewController to have tabsDelegate
extension UIViewController {
    struct Holder {
        static var _tabsDelegate: TabsDelegate?
    }
    var tabsDelegate: TabsDelegate {
        set {
            Holder._tabsDelegate = newValue
        }
        get {
            return Holder._tabsDelegate!
        }
    }
}

extension MainTabBarController: TabsDelegate {
    func menuTapped() {
        //to avoid bad width sizing
        menuViewController = storyboard?.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        menuViewController.modalPresentationStyle = .overCurrentContext
        menuViewController.transitioningDelegate = self
        menuViewController.delegate = self
        present(menuViewController, animated: true)
    }
    func cartMenuTapped() {
        let cartPage = CartViewController()
        self.present(cartPage, animated: false)
    }
    func loginAction() {
        self.login()
    }
}

extension MainTabBarController: ModalDelegate {

    func menuItemsClicked(menuType: MenuType) {
        switch menuType {
        case .login:
            self.login()
        case .wishlist:
                return
        case .my_orders:
            if (self.userSession.logged()) {
                let orderController = OrdersViewController()
                orderController.orderStatus = "all"
                self.present(orderController, animated: true, completion: nil)
            } else {
                self.view.makeToast("Please login first!")
            }
        case .pending_delivery:
            if (self.userSession.logged()) {
                let orderController = OrdersViewController()
                orderController.orderStatus = "processing"
                self.present(orderController, animated: true, completion: nil)
            } else {
                self.view.makeToast("Please login first!")
            }
        case .pending_payments:
            if (self.userSession.logged()) {
                let orderController = OrdersViewController()
                orderController.orderStatus = "pending"
                self.present(orderController, animated: true, completion: nil)
            } else {
                self.view.makeToast("Please login first!")
            }
        case .completed_orders:
            if (self.userSession.logged()) {
                let orderController = OrdersViewController()
                orderController.orderStatus = "complete"
                self.present(orderController, animated: true, completion: nil)
            } else {
                self.view.makeToast("Please login first!")
            }
        case .shipping_address:
            if (self.userSession.logged()) {
                let profileAddress = ProfileAddressViewController()
                self.present(profileAddress, animated: true, completion: nil)
            } else {
                self.view.makeToast("Please login first!")
            }
            return
        case .about_us:
            let browser = BrowserViewController()
            browser.headTitle = "About us"
            browser.url = Site.init().ADDRESS + "about-us"
            self.present(browser, animated: true, completion: nil)
            return
        case .logout:
            self.userSession.logout()
            self.userSession.reload()
        }
    }
}

extension MainTabBarController: MySlideTransitionDelegate {
    func onBackTapped() { //on menu back tapped
        menuViewController.myDismiss()
    }
    
    
}

extension MainTabBarController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.isPresenting = true
        return self.transition
    }
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.isPresenting = false
        return self.transition
    }
}
