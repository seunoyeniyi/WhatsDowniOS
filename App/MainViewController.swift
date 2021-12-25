//
//  MainViewController.swift
//  WhatsDown
//
//  Created by Seun Oyeniyi on 12/24/21.
//  Copyright © 2021 Phuck Brand. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Toast_Swift

class MainViewController: UIViewController {
    
    @IBOutlet var bannerCollectionView: UICollectionView!
    @IBOutlet var productCollectionView: UICollectionView!
    @IBOutlet var productCollectionViewHeightC: NSLayoutConstraint!
    @IBOutlet var bannerShimmer: UIView!
    @IBOutlet var bannerRefreshBtn: UIButton!
    @IBOutlet var productsShimmer: UIView!
    @IBOutlet var productRefreshBtn: UIButton!
    @IBOutlet var topCartBtn: UIBarButtonItem!
    
    let transition = SlideInTransition()
    var menuViewController: MenuViewController!
    let loginViewController = LoginViewController()
    
    var cartNotification: UILabel!
    
    
    let bannerReuseIdentifier: String = "BannerCollectionViewCell"
    let productReuseIdentifier: String = "ProductCardCollectionViewCell"
    
    var banners: Array<Dictionary<String, String>> = []
    var products: Array<Dictionary<String, String>> = []
    
    var defaultPaged = 1
    var currentPaged: Int = 1
    
    var productIsFetching = false
    
    let userSession = UserSession()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMenuController()
        self.setupNavLogo()
        self.removeNavBarBorder()
        
        bannerCollectionView.delegate = self
        bannerCollectionView.dataSource = self
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: (self.view.frame.size.width/2) - 25, height: 210)
        self.productCollectionView.collectionViewLayout = layout
        let productCell = UINib(nibName: productReuseIdentifier, bundle: nil)
        self.productCollectionView.register(productCell, forCellWithReuseIdentifier: productReuseIdentifier)
        
        self.productCollectionView.delegate = self
        self.productCollectionView.dataSource = self
        
        setupCartNotification()
        
        fetchBanners()
        fetchProducts(paged: defaultPaged, shim: true)
        
    }
    
    func setupMenuController() {
        transition.myDelegate = self
        self.modalPresentationStyle = .fullScreen
        menuViewController = storyboard?.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        menuViewController.modalPresentationStyle = .overCurrentContext
        menuViewController.transitioningDelegate = self
        menuViewController.delegate = self
    }
    
    func fetchBanners() {
            if (!Connectivity.isConnectedToInternet) {
                self.view.makeToast("Bad internet connection!")
                self.bannerShimmer.isHidden = false
                self.bannerRefreshBtn.isHidden = false
                return
            }
            
            
            self.bannerShimmer.isHidden = false
            self.bannerRefreshBtn.isHidden = true
            
            
            
            let url = Site.init().BANNERS
            
            Alamofire.request(url).responseJSON { (response) -> Void in
                //check if the result has a value
                if let json_result = response.result.value {
                    let json = JSON(json_result)
                    //print(json)
                    let banners = json["results"]
                    
                    if (banners.count > 0) {
                        
                        for (_, banner): (String, JSON) in banners {
                            self.banners.append([
                                "title": banner["title"].stringValue,
                                "description": banner["description"].stringValue,
                                "image": banner["image"].stringValue,
                                "on_click_to": banner["on_click_to"].stringValue,
                                "category": banner["category"].stringValue,
                                "url": banner["url"].stringValue
                                ])
                        }
                        
                        DispatchQueue.main.async {
                            self.bannerCollectionView.reloadData()
                        }
                        
                        
                        self.bannerShimmer.isHidden = true
                        self.bannerRefreshBtn.isHidden = true
                        
                    } else {
                        self.bannerShimmer.isHidden = false
                        self.bannerRefreshBtn.isHidden = false
                    }
                    
                   
                } else {
                    //no result
                    self.bannerShimmer.isHidden = false
                    self.bannerRefreshBtn.isHidden = false
                }
           
            }
        
        
    }
    
    
    func fetchProducts(paged: Int, shim: Bool) {
        if (!Connectivity.isConnectedToInternet) {
            self.view.makeToast("Bad internet connection!")
            if (shim) {
                self.productsShimmer.isHidden = false
                self.productRefreshBtn.isHidden = false
            }
            return
        }
        
        self.productIsFetching = true
        
        if (shim) {
            self.productsShimmer.isHidden = false
            self.productRefreshBtn.isHidden = true
        }
        
        var url = Site.init().SIMPLE_PRODUCTS + "?orderby=popularity&per_page=20&paged=\(paged)";
        if (userSession.logged()) {
            url += "&user_id=" + userSession.ID;
        }
        
       
        Alamofire.request(url).responseJSON { (response) -> Void in
            //check if the result has a value
            if let json_result = response.result.value {
                let json = JSON(json_result)
                let results = json["results"] //array
                
                for (_, subJson): (String, JSON) in results {
                    let id = subJson["ID"].stringValue;
                    let name = subJson["name"].stringValue;
                    let image = subJson["image"].stringValue;
                    let price = subJson["price"].stringValue;
                    let product_type = subJson["product_type"].stringValue;
                    let ptype = subJson["type"].stringValue;
                    let description = subJson["description"].stringValue;
                    let in_wishlist = subJson["in_wishlist"].stringValue;
//                    let categories = subJson["categories"].stringValue;
                    let stock_status = subJson["stock_status"].stringValue;
                    
                    self.products.append([
                        "ID": id,
                        "name": name,
                        "image": image,
                        "price": price,
                        "product_type": product_type,
                        "type": ptype,
                        "description": description,
                        "in_wishlist": in_wishlist,
                        "stock_status": stock_status
                        ])
                }
                
                DispatchQueue.main.async {
                    self.productCollectionView.reloadData()
                    self.productCollectionViewHeightC.constant = CGFloat((210 + 15) * 10)
//                    self.productCollectionView.layoutIfNeeded()
                }
                
                if json["pagination"].exists() {
                    if json["paged"].exists() {
                        self.currentPaged = Int(json["paged"].stringValue)!
                    }
                }
                //                print(json)
                
                if (shim) {
                    self.productsShimmer.isHidden = true
                    self.productRefreshBtn.isHidden = true
                }
            } else {
                //no result
                if (shim) {
                    self.productsShimmer.isHidden = false
                    self.productRefreshBtn.isHidden = false
                }
            }
            //after every thing
            self.productIsFetching = false
        }
    }
    
    
 
    @IBAction func bannerRefreshTapped(_ sender: Any) {
        fetchBanners()
    }
    @IBAction func productRefreshTapped(_ sender: Any) {
        fetchProducts(paged: currentPaged, shim: true)
    }
    
    @IBAction func newReleaseViewAllTapped(_ sender: Any) {
    }
    @IBAction func trendingViewAllTapped(_ sender: Any) {
    }
    @IBAction func endViewAllTapped(_ sender: Any) {
    }
    
    
    @IBAction func menuTapped(_ sender: Any) {
        //to avoid bad width sizing
        menuViewController = storyboard?.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        menuViewController.modalPresentationStyle = .overCurrentContext
        menuViewController.transitioningDelegate = self
        menuViewController.delegate = self
        present(menuViewController, animated: true)
    }
    
    func login() {
        self.present(loginViewController, animated: true)
    }
    
    @objc func cartMenuTapped(_ sender: UIButton) {
        
    }
    
    func setupCartNotification() {
        let filterBtn = UIButton(type: .system)
        filterBtn.frame = CGRect.init(x: 0, y: 0, width: 30, height: 30)
        filterBtn.setImage(UIImage(named: "icons8_shopping_bag")?.withRenderingMode(.alwaysTemplate), for: .normal)
        filterBtn.tintColor = UIColor.black
        filterBtn.addTarget(self, action: #selector(cartMenuTapped(_:)), for: .touchUpInside)
        
        cartNotification = UILabel.init(frame: CGRect.init(x: 20, y: 2, width: 15, height: 15))
        cartNotification.backgroundColor = UIColor.black
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


extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.bannerCollectionView {
            return self.banners.count
        }
        return self.products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.bannerCollectionView { //for banner
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: bannerReuseIdentifier, for: indexPath) as! BannerCollectionViewCell
            cell.bannerImage.pin_setImage(from: URL(string: self.banners[indexPath.row]["image"]!))
            cell.bannerTitle.text = (self.banners[indexPath.row]["title"]!).replacingOccurrences(of: "\\", with: "")
            cell.bannerDescription.text = (self.banners[indexPath.row]["description"]!).replacingOccurrences(of: "\\", with: "")
            
            return cell
        } else { //else for product
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: productReuseIdentifier, for: indexPath) as! ProductCardCollectionViewCell
            cell.parentView = self.view
            cell.cardDelegate = self
            cell.productID = self.products[indexPath.row]["ID"]!
            cell.hasWishList = self.products[indexPath.row]["in_wishlist"]! == "true"
            cell.productImage.pin_setImage(from: URL(string: self.products[indexPath.row]["image"]!))
            cell.productTitle.text = self.products[indexPath.row]["name"]!
            
            if self.products[indexPath.row]["product_type"]! == "variable" || self.products[indexPath.row]["type"]! == "variable" {
                cell.productPrice.text = "From " + Site.init().CURRENCY + self.products[indexPath.row]["price"]!
            } else {
                cell.productPrice.text = Site.init().CURRENCY + self.products[indexPath.row]["price"]!
            }
            
            
            return cell
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.bannerCollectionView {
            return CGSize(width: 206, height: 178)
        } else {
            return CGSize(width: (self.view.frame.size.width/2) - 25, height: 210)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = UIColor(rgb: 0xF1F1F1)
    }
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = UIColor(rgb: 0xFFFFFF)
    }
 
    
}

extension MainViewController: ProductCardDelegate {
    func updateWishlist(product_id: String, action: String) {
        if (userSession.logged()) {
            self.doUpdateWishlist(user_id: userSession.ID, product_id: product_id, action: action)
        } else {
            self.view.makeToast("Please login first!")
        }
        
    }
}



//FOR MENU CONTROLLER
extension MainViewController: ModalDelegate {
    
    
    func menuItemsClicked(menuType: MenuType) {
        switch menuType {
        case .login:
            self.login()
            return
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

extension MainViewController: MySlideTransitionDelegate {
    func onBackTapped() { //on menu back tapped
        menuViewController.myDismiss()
    }
    
    
}

extension MainViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.isPresenting = true
        return self.transition
    }
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.isPresenting = false
        return self.transition
    }
}

