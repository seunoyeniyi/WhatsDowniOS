//
//  ProductViewController.swift
//  Phuck Brand
//
//  Created by Seun Oyeniyi on 11/21/21.
//  Copyright © 2021 Phuck Brand. All rights reserved.
//

import UIKit
import Toast_Swift
import Alamofire
import SwiftyJSON



class ProductViewController: UIViewController {
    
    
    @IBOutlet var topCartBtn: UIBarButtonItem!
    @IBOutlet var topNavigationItem: UINavigationItem!
    @IBOutlet var topNavigationBar: UINavigationBar!
    
    @IBOutlet var thumbnailView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var priceView: UIView!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var addToCartContainer: UIView!
    @IBOutlet var increaseBtn: UIButton!
    @IBOutlet var decreaseBtn: UIButton!
    @IBOutlet var qauntityLabel: UILabel!
    @IBOutlet var addToCartBtn: UIButton!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var attributesTableView: UITableView!
    @IBOutlet var attributePriceLabel: UILabel!
    @IBOutlet var attributePriceLabelHeightC: NSLayoutConstraint! // 20
    @IBOutlet var attrTableViewHeightC: NSLayoutConstraint!
    @IBOutlet var cartActivity: UIActivityIndicatorView!
    @IBOutlet var refreshBtn: UIButton!
    @IBOutlet var wishListBtn: WishListButton!
    @IBOutlet var galleryCollectionView: UICollectionView!
    
    let userSession = UserSession()
    
    let theCart = AddToCart()
    
    var productID: String!
    var productName: String!
    var productImage: String!
    var productPrice: String!
    var productType: String!
    var productType2: String!
    var productDescription: String!
    var in_wishlist: Bool = false
    var parentID: String!

    var cartProductID: String!
    
    var quantity: Int = 1
    
    var cartNotification: UILabel!
    
    let galleryReuseIdentifier = "GalleryCollectionViewCell"
    var galleries: Array<String> = []
    
    var attributes: Array<Dictionary<String, Any>> = []
    let attributeCellReuseIdentifier = "AttributeTableViewCell"
    
    var selectedOptions: Dictionary<String, String> = [:]
    var variations: JSON = JSON.null
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.parentID = productID //for the first tiem
        
        topNavigationBar.setBackgroundImage(UIImage(), for: .default)
        topNavigationBar.shadowImage = UIImage()
        topNavigationBar.isTranslucent = true
        topNavigationBar.backgroundColor = .clear
        
        
        setBackButton()
        setupCartNotification()
        
        self.theCart.delegate = self
        
        
        self.galleries.append(productImage) //add the comming url first
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: (self.view.frame.size.width - 50), height: 400)
        self.galleryCollectionView.collectionViewLayout = layout
        let galleryCell = UINib(nibName: galleryReuseIdentifier, bundle: nil)
        self.galleryCollectionView.register(galleryCell, forCellWithReuseIdentifier: galleryReuseIdentifier)
        
        self.galleryCollectionView.delegate = self
        self.galleryCollectionView.dataSource = self
        
        
        
        
        

        //wishlist button
        if (in_wishlist) {
            self.wishListBtn.setImage(UIImage(named: "icons8_heart_outline_1"), for: .normal)
        } else {
            self.wishListBtn.setImage(UIImage(named: "icons8_heart_outline"), for: .normal)
        }
        

        thumbnailView.pin_setImage(from: URL(string: productImage)!)
        titleLabel.text = productName
        descriptionLabel.attributedText = productDescription.htmlToAttributedString
        cartProductID = productID
      
        
        let attrCell = UINib(nibName: attributeCellReuseIdentifier, bundle: nil)
        self.attributesTableView.register(attrCell, forCellReuseIdentifier: attributeCellReuseIdentifier)
        self.attributesTableView.tableFooterView = UIView()//to remove the extra empty cell divider lines
        
        attributesTableView.delegate = self
        attributesTableView.dataSource = self
        attrTableViewHeightC.constant = 0
        attributesTableView.isHidden = true
        attributePriceLabelHeightC.constant = 0
        attributePriceLabel.isHidden = true
        priceLabel.isHidden = true
        addToCartContainer.isHidden = true
        refreshBtn.isHidden = true
        cartActivity.isHidden = false
        
        
        fetchDetail()
        
    }
    
    func setBackButton() {
        let backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 70.0, height: 80.0))
        backButton.setImage(UIImage(named: "icons8_back"), for: .normal)
        backButton.tintColor = UIColor.black
        backButton.titleEdgeInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 0.0)
        backButton.setTitle("Back", for: .normal)
        backButton.titleLabel?.font = backButton.titleLabel?.font.withSize(14)
        backButton.setTitleColor(UIColor.black, for: .normal)
        backButton.setTitleColor(UIColor.gray, for: .focused)
        backButton.setTitleColor(UIColor.gray, for: .highlighted)
        backButton.addTarget(self, action: #selector(backTapped(_:)), for: .touchUpInside)
        
        let backBarButton = UIBarButtonItem(customView: backButton)
        
        let spacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
        
        spacer.width = -15
        
        topNavigationItem.leftBarButtonItems = [spacer, backBarButton]
    }
    
    
    
    
    
    func fetchDetail() {
        if (!Connectivity.isConnectedToInternet) {
            self.view.makeToast("Bad internet connection!")
            attrTableViewHeightC.constant = 0
            attributesTableView.isHidden = true
            attributePriceLabelHeightC.constant = 0
            attributePriceLabel.isHidden = true
            priceLabel.isHidden = true
            addToCartContainer.isHidden = true
            refreshBtn.isHidden = false
            cartActivity.isHidden = true
            return
        }
        
        
        attrTableViewHeightC.constant = 0
        attributesTableView.isHidden = true
        attributePriceLabelHeightC.constant = 0
        attributePriceLabel.isHidden = true
        priceLabel.isHidden = true
        addToCartContainer.isHidden = true
        refreshBtn.isHidden = true
        cartActivity.isHidden = false
        
        let url = Site.init().PRODUCT + productID + "?user_id=" + userSession.ID
        
        Alamofire.request(url).responseJSON { (response) -> Void in
            //check if the result has a value
            if let json_result = response.result.value {
                let json = JSON(json_result)
                
                //set galleries
                self.galleries = []
                self.galleries.append(self.productImage)//add the thumbnail
                
                for (_, url): (String, JSON) in json["gallery_images"] {
                    self.galleries.append(url.stringValue)
                }
                DispatchQueue.main.async {
                    self.galleryCollectionView.reloadData()
                }
                
                
                //for category tag after titlte
                let categories = json["categories"]
                if (categories.count > 0) {
                    let category = categories[0]
                    self.categoryLabel.text = category["name"].stringValue
                }
                
                
                
                if (json["type"].stringValue == "variable" || json["product_type"].stringValue == "variable") {
                    self.priceLabel.text = "From " + Site.init().CURRENCY + PriceFormatter.format(price: json["price"].stringValue)
                    self.variations = json["variations"]
                    //update attributes table view
                    let attributes = json["attributes"];
                    for (_, attribute): (String, JSON) in attributes {
                        self.attributes.append([
                            "name": attribute["name"].stringValue,
                            "options": attribute["options"],
                            "label": attribute["label"].stringValue,
                            ])
                    }
                    DispatchQueue.main.async {
                        self.attributesTableView.reloadData()
                        self.attrTableViewHeightC.constant = CGFloat(80 * attributes.count) //self.attributesTableView.contentSize.height
                        self.attributesTableView.isHidden = false
                    }
                } else { //simple product
                    self.priceLabel.text = Site.init().CURRENCY + PriceFormatter.format(price: json["price"].stringValue)
                }
                
                
                DispatchQueue.main.async {
                    
                }
                
                
                self.priceLabel.isHidden = false
                self.addToCartContainer.isHidden = false
                self.refreshBtn.isHidden = true
        
            } else {
                //no result
                self.view.makeToast("Can't get product details... Try again!")
                self.attrTableViewHeightC.constant = 0
                self.attributesTableView.isHidden = true
                self.attributePriceLabelHeightC.constant = 0
                self.attributePriceLabel.isHidden = true
                self.priceLabel.isHidden = true
                self.addToCartContainer.isHidden = true
                self.refreshBtn.isHidden = false
            }
            //after every thing
            self.cartActivity.isHidden = true
        }
        
    }
    
    
    
    
    @IBAction func refreshTapped(_ sender: Any) {
        fetchDetail()
    }
    
    
    @IBAction func addToCartTapped(_ sender: Any) {
        self.view.makeToast("Adding Product to cart...", position: .top)
        self.theCart.addToCart(productID: cartProductID, quantity: self.quantity)
    }
    @objc func menuCartTapped(_ sender: Any) {
        
    }
    
    
    
    @IBAction func increaseBtnTapped(_ sender: Any) {
        self.quantity += 1
        self.qauntityLabel.text = String(quantity)
    }
    @IBAction func decreaseBtnTapped(_ sender: Any) {
        if (quantity > 1) {
            self.quantity -= 1
        }
        self.qauntityLabel.text = String(quantity)
    }
    
    
    @IBAction func wishListBtnTapped(_ sender: WishListButton) {
        if (userSession.logged()) {

            
            if (in_wishlist) {
                self.doUpdateWishlist(user_id: userSession.ID, product_id: self.parentID, action: "remove")
                self.in_wishlist = false
                self.wishListBtn.setImage(UIImage(named: "icons8_heart_outline"), for: .normal)
            } else {
                self.doUpdateWishlist(user_id: userSession.ID, product_id: self.parentID, action: "add")
                self.in_wishlist = true
                self.wishListBtn.setImage(UIImage(named: "icons8_heart_outline_1"), for: .normal)
            }
            
        } else {
            self.view.makeToast("Please login first!")
        }
        
        
    }
    
    @objc func backTapped(_ sender: Any) {
        self.dismissWithCondition(animated: true, completion: nil)
    }
    //to hide default navigation bar
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    @objc func cartMenuTapped(_ sender: UIButton) {
        let cartPage = CartViewController()
        self.presentWithCondition(controller: cartPage, animated: true, completion: nil)
    }
    
    func setupCartNotification() {
        let filterBtn = UIButton(type: .system)
        filterBtn.frame = CGRect.init(x: 0, y: 0, width: 30, height: 30)
        filterBtn.setImage(UIImage(named: "icons8_shopping_bag")?.withRenderingMode(.alwaysTemplate), for: .normal)
        filterBtn.tintColor = UIColor.black
        filterBtn.addTarget(self, action: #selector(cartMenuTapped(_:)), for: .touchUpInside)
        
        self.cartNotification = UILabel.init(frame: CGRect.init(x: 20, y: 2, width: 15, height: 15))
        self.cartNotification.backgroundColor = UIColor.black
        self.cartNotification.clipsToBounds = true
        self.cartNotification.layer.cornerRadius = 7
        self.cartNotification.textColor = UIColor.white
        self.cartNotification.font = cartNotification.font.withSize(10)
        self.cartNotification.textAlignment = .center
        self.cartNotification.text = "0"
        filterBtn.addSubview(cartNotification)
        self.topCartBtn.customView = filterBtn
        
        self.cartNotification.isHidden = true //hidden by default
        
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

//FOR ATTRIBUTES TABLE
extension ProductViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.attributes.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.attributesTableView.dequeueReusableCell(withIdentifier: attributeCellReuseIdentifier) as! AttributeTableViewCell
        cell.titleLabel?.text = (self.attributes[indexPath.row]["label"] as? String)?.capitalizingFirstLetter()
        cell.attributeName = self.attributes[indexPath.row]["name"] as? String
        cell.attributeDelegate = self
        
        if let options = self.attributes[indexPath.row]["options"] as? JSON {
            for (_, option): (String, JSON) in options {
                cell.options.append([
                    "name": option["name"].stringValue,
                    "value": option["value"].stringValue
                    ])
            }
        }
        
        cell.dropDown.isSearchEnable = false
        
        var optionsString: Array<String> = []
        for option in cell.options {
            optionsString.append(option["value"]!)
        }
        
        
        cell.dropDown.optionArray = optionsString
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}


//FOR ATTRIBUTE OPTIONS SELECTION
extension ProductViewController: AttributeSelect {
    
    func attributeSelected(name: String, value: String) {
        selectedOptions[name] = value;
        getMatchedAttributesOfVariation();
    }
    
    func getMatchedAttributesOfVariation() {
        
        if variations != JSON.null {
            var matchFound = false;
            for (_, variation): (String, JSON) in variations {
                let attributes = variation["attributes"]
                //now let convert it's attributes to Dictionary to be able to compare with selected options
                var compareAttributes: Dictionary<String, String> = [:]
                for (_, attribute): (String, JSON) in attributes {
                    for (key, value): (String, JSON) in attribute {
                        compareAttributes[key] = value.stringValue
                    }
                }
                //now let compare selectedOptions with each compareAttributes in the loop
                if NSDictionary(dictionary: selectedOptions).isEqual(to: compareAttributes) {
                    matchFound = true
                    self.attributePriceLabel.text = "$" + PriceFormatter.format(price: variation["price"].stringValue)
                    self.cartProductID = variation["ID"].stringValue
                    self.attributePriceLabel.isHidden = false
                    self.attributePriceLabelHeightC.constant = 20
                    self.addToCartBtn.isEnabled = true
                }
            }
            if (!matchFound) {
                self.attributePriceLabel.isHidden = true
                self.attributePriceLabelHeightC.constant = 0
                self.addToCartBtn.isEnabled = false
                self.cartProductID = "0"
            }
        }
        
        
    }

    
}

extension ProductViewController: AddToCartDelegate {
    func cartAdded(totalItems: String, subTotal: String, total: String) {
        var style = ToastStyle()
        style.imageSize = CGSize(width: 20, height: 20)
        
        let totalItemsInt: Int = Int(totalItems) ?? 0
        
        if (totalItemsInt > 0) {
            self.cartNotification.text = totalItems
            self.cartNotification.isHidden = false
            self.view.makeToast("Product added to cart!", position: .top, image: UIImage(named: "icons8_checked"), style: style)
        } else {
            self.cartNotification.isHidden = true
        }
    }
    
    func cartNotAdded(msg: String) {
        self.view.makeToast(msg)
    }
    
    
}






extension ProductViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.galleries.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: galleryReuseIdentifier, for: indexPath) as! GalleryCollectionViewCell
                cell.imageItem.pin_setImage(from: URL(string: self.galleries[indexPath.row]))
            
            return cell
  
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if (self.galleries.count > 1) {
            return CGSize(width: (self.view.frame.size.width - 50), height: 400)
        } else {
            return CGSize(width: self.view.frame.size.width, height: 400)
        }
        
    }
    
   
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       //did selected
    }
    
}

