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
    
    
    let bannerReuseIdentifier: String = "BannerCollectionViewCell"
    let productReuseIdentifier: String = "ProductCardCollectionViewCell"
    
    var banners: Array<Dictionary<String, String>> = []
    var products: Array<Dictionary<String, String>> = []
    
    var defaultPaged = 1
    var currentPaged: Int = 1
    
    var productIsFetching = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        fetchBanners()
        fetchProducts(paged: defaultPaged, shim: true)
        
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
                    print(json)
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
        
        let url = Site.init().SIMPLE_PRODUCTS + "?per_page=20&paged=\(paged)";
        
       
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
                    
                    self.products.append([
                        "ID": id,
                        "name": name,
                        "image": image,
                        "price": price,
                        "product_type": product_type,
                        "type": ptype,
                        "description": description,
                        ])
                }
                
                DispatchQueue.main.async {
                    self.productCollectionView.reloadData()
                
                    self.productCollectionViewHeightC.constant = CGFloat(150 * (self.products.count / 2))
                    self.productCollectionView.setNeedsLayout()
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
 
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (indexPath.row == products.count - 5 && !self.productIsFetching) {
            let nextPage = self.currentPaged + 1
            fetchProducts(paged: nextPage, shim: false)
        }
    }
    
}
