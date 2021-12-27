//
//  WishlistViewController.swift
//  WhatsDown
//
//  Created by Seun Oyeniyi on 12/27/21.
//  Copyright © 2021 Phuck Brand. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class WishlistViewController: NoBarViewController {
    @IBOutlet var topNavigationItem: UINavigationItem!
    @IBOutlet var topCartBtn: UIBarButtonItem!
    @IBOutlet var productCollectionView: UICollectionView!
    @IBOutlet var productShimmerContainer: ShimmerViewContainer!
    @IBOutlet var refreshBtn: UIButton!
    @IBOutlet var errorLbl: UILabel!
    
    var cartNotification: UILabel!
    
    
    let productReuseIdentifier: String = "ProductCardCollectionViewCell"
    
    var products: Array<Dictionary<String, String>> = []
    
    var defaultPaged = 1
    var currentPaged: Int = 1
    
    var productIsFetching = false
    
    let userSession = UserSession()
    

    var productPage = ProductViewController()
    var cartController = CartViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
   
      
        
        errorLbl.isHidden = true
        
        let productsShimmerlayout = ProductsShimmerController()
        productShimmerContainer.addSubview(productsShimmerlayout.view)
        productShimmerContainer.sendSubview(toBack: productsShimmerlayout.view)
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: (self.view.frame.size.width/2) - 25, height: 210)
        self.productCollectionView.collectionViewLayout = layout
        let productCell = UINib(nibName: productReuseIdentifier, bundle: nil)
        self.productCollectionView.register(productCell, forCellWithReuseIdentifier: productReuseIdentifier)
        
        self.productCollectionView.delegate = self
        self.productCollectionView.dataSource = self
        
        setupCartNotification()
        
    
        
        fetchProducts(paged: defaultPaged, shim: true)
        
        
    }
    
    
    func fetchProducts(paged: Int, shim: Bool, emptyProducts: Bool = false) {
        if (!Connectivity.isConnectedToInternet) {
            self.view.makeToast("Bad internet connection!")
            if (shim) {
                self.productShimmerContainer.isHidden = false
                self.productShimmerContainer.stopShimmering()
                self.refreshBtn.isHidden = false
            }
            return
        }
        
        self.productIsFetching = true
        
        if (shim) {
            self.productShimmerContainer.isHidden = false
            self.productShimmerContainer.startShimmering()
            self.refreshBtn.isHidden = true
            self.errorLbl.isHidden = true
        }
        
        
        let url = Site.init().WISH_LIST + userSession.ID;
       
      
        
        Alamofire.request(url).responseJSON { (response) -> Void in
            //check if the result has a value
            if let json_result = response.result.value {
                let json = JSON(json_result)
                let results = json["results"] //array
                
                if (emptyProducts) {
                    self.products = []
                }
                
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
                    //                    self.productCollectionView.layoutIfNeeded()
                }
                
                if json["pagination"].exists() {
                    if json["paged"].exists() {
                        self.currentPaged = Int(json["paged"].stringValue)!
                    }
                }
                //                print(json)
                
                if (shim) {
                    self.productShimmerContainer.isHidden = true
                    self.productShimmerContainer.stopShimmering()
                    self.refreshBtn.isHidden = true
                }
            } else {
                //no result
                if (shim) {
                    self.productShimmerContainer.isHidden = false
                    self.productShimmerContainer.stopShimmering()
                    self.refreshBtn.isHidden = false
                    self.errorLbl.isHidden = false
                }
            }
            //after every thing
            self.productIsFetching = false
        }
    }
    
    
    @IBAction func refreshBtnTapped(_ sender: Any) {
        fetchProducts(paged: currentPaged, shim: true, emptyProducts: true)
    }
    @IBAction func backTapped(_ sender: Any) {
        if (self.isModal) {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    

    
    @objc func cartMenuTapped(_ sender: UIButton) {
        cartController = CartViewController()
        self.presentWithCondition(controller: cartController, animated: true, completion: nil)
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
    
    
    override func viewDidAppear(_ animated: Bool) {
        self.userSession.reload()
        self.updateCartNotification()
    }
}




extension WishlistViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: productReuseIdentifier, for: indexPath) as! ProductCardCollectionViewCell
        cell.parentView = self.view
        cell.cardDelegate = self
        cell.productID = self.products[indexPath.row]["ID"]!
        cell.hasWishList = self.products[indexPath.row]["in_wishlist"]! == "true"
        cell.productImage.pin_setImage(from: URL(string: self.products[indexPath.row]["image"]!))
        cell.productTitle.text = self.products[indexPath.row]["name"]!
        
        //variable
        if self.products[indexPath.row]["product_type"]! == "variable" || self.products[indexPath.row]["type"]! == "variable" {
            cell.productPrice.text = "From " + Site.init().CURRENCY + PriceFormatter.format(price: self.products[indexPath.row]["price"]!)
        } else { //single product
            cell.productPrice.text = Site.init().CURRENCY + PriceFormatter.format(price: self.products[indexPath.row]["price"]!)
        }
        //wishlist button
        if (cell.hasWishList) {
            cell.wishListBtn.setImage(UIImage(named: "icons8_heart_outline_1"), for: .normal)
        } else {
            cell.wishListBtn.setImage(UIImage(named: "icons8_heart_outline"), for: .normal)
        }
        
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (self.view.frame.size.width/2) - 25, height: 210)
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = UIColor(rgb: 0xF1F1F1)
    }
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = UIColor(rgb: 0xFFFFFF)
    }
    
    //SELECTION
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        productPage = ProductViewController()
        productPage.productID = self.products[indexPath.item]["ID"]!
        productPage.productName = self.products[indexPath.item]["name"]!
        productPage.productImage = self.products[indexPath.item]["image"]!
        productPage.productPrice = self.products[indexPath.item]["price"]!
        productPage.productType = self.products[indexPath.item]["product_type"]!
        productPage.productType2 = self.products[indexPath.item]["type"]!
        productPage.productDescription = self.products[indexPath.item]["description"]!
        productPage.in_wishlist = self.products[indexPath.item]["in_wishlist"]! == "true"
        
        self.presentWithCondition(controller: productPage, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (indexPath.row == self.products.count - 5 && !self.productIsFetching) {
            let nextPage = self.currentPaged + 1
            fetchProducts(paged: nextPage, shim: false)
        }
    }
}

extension WishlistViewController: ProductCardDelegate {
    func updateWishlist(product_id: String, action: String) {
        if (userSession.logged()) {
            self.doUpdateWishlist(user_id: userSession.ID, product_id: product_id, action: action)
        } else {
            self.view.makeToast("Please login first!")
        }
        
    }
}



