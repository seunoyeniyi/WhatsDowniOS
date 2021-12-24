//
//  ShopDataViewController.swift
//  Phuck Brand
//
//  Created by Seun Oyeniyi on 11/13/21.
//  Copyright © 2021 Phuck Brand. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import PINRemoteImage

class ShopDataViewController: UIViewController {
    
    
    @IBOutlet var productsCollectionView: UICollectionView!
    @IBOutlet var loadingView: UIView!
    @IBOutlet var loadingActivity: UIActivityIndicatorView!
    @IBOutlet var refreshBtn: UIButton!
    
    let reuseCellIdentity: String = "product_cell"
    
    var index: Int?
    var category: Dictionary<String, Any> = [
        "name": "All",
        "slug": "all"
    ];
    
    
    var productLists: Array<Dictionary<String, Any>> = [];
    var defaultPaged: String = "1";
    var currentPaged: Int = 1;
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingActivity.transform = CGAffineTransform(scaleX: 2, y: 2)
        fetchProducts(paged: defaultPaged, showDialog: true)
    }

    func fetchProducts(paged: String, showDialog: Bool) {
        if (!Connectivity.isConnectedToInternet) {
            self.view.makeToast("Bad internet connection!")
            if (showDialog) {
                self.loadingView.isHidden = false
                self.loadingActivity.isHidden = true
                self.refreshBtn.isHidden = false
            }
            return
        }
        if (showDialog) {
            self.loadingView.isHidden = false
            self.loadingActivity.isHidden = false
            self.refreshBtn.isHidden = true
        }
        
        var url = Site.init().SIMPLE_PRODUCTS + "?per_page=20&cat=" + "\(category["slug"] ?? "")" + "&paged=" + paged;
        
        if ("\(category["slug"] ?? "all")" == "all") {
            url = Site.init().SIMPLE_PRODUCTS + "?per_page=20&paged=" + paged;
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
               
                    self.productLists.append([
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
                    self.productsCollectionView.reloadData()
                }
                
                if json["pagination"].exists() {
                    if json["paged"].exists() {
                        self.currentPaged = Int(json["paged"].stringValue)!
                    }
                }
//                print(json)
                
                if (showDialog) {
                    self.loadingView.isHidden = true
                }
            } else {
                //no result
//                self.view.makeToast("0 products... Try Again!")
                if (showDialog) {
                    self.loadingView.isHidden = false
                    self.loadingActivity.isHidden = true
                    self.refreshBtn.isHidden = false
                }
            }
            //after every thing
        }
    }
    @IBAction func refreshTapped(_ sender: Any) {
        fetchProducts(paged: defaultPaged, showDialog: true)
    }
    

}

extension ShopDataViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.productLists.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //get a reference to our story board
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseCellIdentity, for: indexPath) as! ProductCollectionViewCell
        //use the outlet in our custom calss to get a reference to the UILabel in the cell
        cell.layer.cornerRadius = 5
        cell.clipsToBounds = true
        cell.layer.borderColor = UIColor.white.cgColor
        cell.layer.borderWidth = 1
        
        //set cell title, image and price
        cell.titleLabel.text = productLists[indexPath.row]["name"] as? String
        cell.priceLabel.text = "$" + "\(productLists[indexPath.row]["price"] ?? "?")"
        cell.imageView.pin_setImage(from: URL(string: productLists[indexPath.row]["image"] as! String)!)
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //handle tap events
        let productPage = ProductViewController()
        productPage.productID = "\(self.productLists[indexPath.item]["ID"] ?? "0")"
        productPage.productName = "\(self.productLists[indexPath.item]["name"] ?? "name?")"
        productPage.productImage = "\(self.productLists[indexPath.item]["image"] ?? "image?")"
        productPage.productPrice = "\(self.productLists[indexPath.item]["price"] ?? "0?")"
        productPage.productType = "\(self.productLists[indexPath.item]["product_type"] ?? "type?")"
        productPage.productType2 = "\(self.productLists[indexPath.item]["type"] ?? "type?")"
        productPage.productDescription = "\(self.productLists[indexPath.item]["description"] ?? "description?")"
        self.present(productPage, animated: false)
//        self.navigationController?.pushViewController(productPage, animated: false)
        //        print("You selected cell #\(indexPath.item)!")
    }
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = UIColor(rgb: 0xF1F1F1)
    }
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = UIColor(rgb: 0xFFFFFF)
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
//        let cell = collectionView.cellForItem(at: indexPath)
//        cell?.backgroundColor = UIColor(rgb: 0xFFFFFF)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (indexPath.row == productLists.count - 5) {
            let nextPage = self.currentPaged + 1
            fetchProducts(paged: "\(nextPage)", showDialog: false)
        }
    }
}


