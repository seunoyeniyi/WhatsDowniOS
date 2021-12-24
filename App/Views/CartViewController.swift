//
//  CartViewController.swift
//  Phuck Brand
//
//  Created by Seun Oyeniyi on 12/2/21.
//  Copyright © 2021 Phuck Brand. All rights reserved.
//

import UIKit
import SwiftyJSON
import Toast_Swift
import Alamofire

class CartViewController: UIViewController {

    @IBOutlet var carNavigationBar: UINavigationBar!
    @IBOutlet var cartNavigationItem: UINavigationItem!
    @IBOutlet var topCartBtn: UIBarButtonItem!
    @IBOutlet var cartEmptyLbl: UILabel!
    @IBOutlet var cartTableView: UITableView!
    @IBOutlet var cartTableViewHeightC: NSLayoutConstraint!
    @IBOutlet var couponView: UIView!
    @IBOutlet var couponViewHeightC: NSLayoutConstraint!
    @IBOutlet var totalView: UIView!
    @IBOutlet var subtotalLbl: UILabel!
    @IBOutlet var totalLbl: UILabel!
    @IBOutlet var completeBtn: UIButton!
    @IBOutlet var continueShoppingBtn: UIButton!
    @IBOutlet var totalViewHeightC: NSLayoutConstraint!
    @IBOutlet var cartActivity: UIActivityIndicatorView!
    @IBOutlet var applyCouponBtn: UIButton!
    @IBOutlet var couponTextField: UITextField!
    @IBOutlet var tryAgainBtn: UIButton!
    @IBOutlet var totalProgressView: UIView!
    
    var cartNotification: UILabel!
    
    
    let userSession = UserSession()
    
    let theCart = AddToCart()
    
    let cartCellReuseIdentifier = "CartTableViewCell"
    
    var cartProducts: Array<Dictionary<String, String>> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBackButton()
        setupCartNotification()
        
        self.theCart.delegate = self

        let cartCell = UINib(nibName: cartCellReuseIdentifier, bundle: nil)
        self.cartTableView.register(cartCell, forCellReuseIdentifier: cartCellReuseIdentifier)
        self.cartTableView.tableFooterView = UIView()//to remove the extra empty cell divider lines
        
        self.cartTableView.delegate = self
        self.cartTableView.dataSource = self
        self.cartTableViewHeightC.constant = 0
        self.cartTableView.isHidden = true
        self.couponView.isHidden = true
        self.couponViewHeightC.constant = 0
        self.totalView.isHidden = true
        self.totalViewHeightC.constant = 0
        self.cartActivity.isHidden = false
        self.cartEmptyLbl.isHidden = true
        self.tryAgainBtn.isHidden = true
        self.totalProgressView.isHidden = true
        
        styleThisBtn(btn: completeBtn)
        styleThisBtn(btn: applyCouponBtn)
        styleThisBtn(btn: continueShoppingBtn)
        styleThisBtn(btn: tryAgainBtn)
        
        cartActivity.transform = CGAffineTransform(scaleX: 2, y: 2)
        
        fetchCart();
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
        
        cartNavigationItem.leftBarButtonItems = [spacer, backBarButton]
    }
    @objc func backTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func fetchCart() {
        if (!Connectivity.isConnectedToInternet) {
            self.view.makeToast("Bad internet connection!")
            self.cartTableViewHeightC.constant = 0
            self.cartTableView.isHidden = true
            self.couponView.isHidden = true
            self.couponViewHeightC.constant = 0
            self.totalView.isHidden = true
            self.totalViewHeightC.constant = 0
            self.cartActivity.isHidden = true
            self.cartEmptyLbl.isHidden = false
            self.tryAgainBtn.isHidden = false
            self.continueShoppingBtn.isHidden = true
            return
        }
        
        self.cartTableViewHeightC.constant = 0
        self.cartTableView.isHidden = true
        self.couponView.isHidden = true
        self.couponViewHeightC.constant = 0
        self.totalView.isHidden = true
        self.totalViewHeightC.constant = 0
        self.cartActivity.isHidden = false
        self.cartEmptyLbl.isHidden = true
        self.tryAgainBtn.isHidden = true
        self.continueShoppingBtn.isHidden = true
        
        let url = Site.init().CART + userSession.ID
        
        Alamofire.request(url).responseJSON { (response) -> Void in
            //check if the result has a value
            if let json_result = response.result.value {
                let json = JSON(json_result)
//                print(json)
                if (json["items"].exists()) {
                    let items = json["items"]
                    if (items.count < 1) {
                        //no result 
                        self.view.makeToast("Empty Cart!")
                        self.cartTableViewHeightC.constant = 0
                        self.cartTableView.isHidden = true
                        self.couponView.isHidden = true
                        self.couponViewHeightC.constant = 0
                        self.totalView.isHidden = true
                        self.totalViewHeightC.constant = 0
                        self.cartActivity.isHidden = true
                        self.cartEmptyLbl.isHidden = false
                        self.tryAgainBtn.isHidden = false
                        self.continueShoppingBtn.isHidden = true
                    } else {
                    
                        self.cartProducts = []
                        for (_, item): (String, JSON) in items {
                            self.cartProducts.append([
                                "ID" : item["ID"].stringValue,
                                "quantity" : item["quantity"].stringValue,
                                "price" : item["price"].stringValue,
                                "product_title" : item["product_title"].stringValue,
                                "product_image" : item["product_image"].stringValue,
                                ])
                        }
                        
                        DispatchQueue.main.async {
                            self.cartTableView.reloadData()
                            self.cartTableViewHeightC.constant = CGFloat(90 * self.cartProducts.count)
                            self.cartTableView.isHidden = false
                        }
                        let subtotalDouble: Double = json["subtotal"].doubleValue
                        
                        self.subtotalLbl.text = Site.init().CURRENCY + PriceFormatter.format(price: subtotalDouble)
                        //TODO: change this for another project - coupon might be added
                        self.totalLbl.text = Site.init().CURRENCY + PriceFormatter.format(price: subtotalDouble)
                        
                        
                        if (subtotalDouble < 1) {
                            self.completeBtn.isEnabled = false
                        }
                        
                        self.couponView.isHidden = true// false for other project
                        self.couponViewHeightC.constant = 0 //50 for other project
                        self.totalView.isHidden = false
                        self.totalViewHeightC.constant = 130
                        self.cartActivity.isHidden = true
                        self.cartEmptyLbl.isHidden = true
                        self.tryAgainBtn.isHidden = true
                        self.continueShoppingBtn.isHidden = false
                        
                    }
                    
                    
                } else {
                    //no result
                    self.view.makeToast("Empty Cart!")
                    self.cartTableViewHeightC.constant = 0
                    self.cartTableView.isHidden = true
                    self.couponView.isHidden = true
                    self.couponViewHeightC.constant = 0
                    self.totalView.isHidden = true
                    self.totalViewHeightC.constant = 0
                    self.cartActivity.isHidden = true
                    self.cartEmptyLbl.isHidden = false
                    self.tryAgainBtn.isHidden = false
                }
                
                
                
         
                
            } else {
                //no result
                self.view.makeToast("Empty Cart!")
                self.cartTableViewHeightC.constant = 0
                self.cartTableView.isHidden = true
                self.couponView.isHidden = true
                self.couponViewHeightC.constant = 0
                self.totalView.isHidden = true
                self.totalViewHeightC.constant = 0
                self.cartActivity.isHidden = true
                self.cartEmptyLbl.isHidden = false
                self.tryAgainBtn.isHidden = false
            }
            //after every thing
            self.cartActivity.isHidden = true
        }
        
        
        
    }
    
    @IBAction func applyCouponTapped(_ sender: Any) {
        
    }
    @IBAction func tryAgainTapped(_ sender: Any) {
        fetchCart()
    }
    @IBAction func completeOrderTapped(_ sender: Any) {
        let checkoutController = CheckoutAddressViewController()
        checkoutController.presentationDelegate = self
        if (userSession.logged()) {
            self.present(checkoutController, animated: true, completion: nil)
        } else {
            let loginViewController = LoginViewController()
            loginViewController.onDoneBlock = { logged in
                //refresh userSession
                self.userSession.reload()
                if (self.userSession.logged()) {
                    self.present(checkoutController, animated: true, completion: nil)
                }
            }
            self.present(loginViewController, animated: true)
        }
        
    }
    @IBAction func continueShoppingTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func cartMenuTapped(_ sender: UIButton) {
        fetchCart()
    }
    
    func setupCartNotification() {
        let filterBtn = UIButton(type: .system)
        filterBtn.frame = CGRect.init(x: 0, y: 0, width: 30, height: 30)
        filterBtn.setImage(UIImage(named: "icons8_shopping_cart")?.withRenderingMode(.alwaysTemplate), for: .normal)
        filterBtn.tintColor = UIColor.black
        filterBtn.addTarget(self, action: #selector(cartMenuTapped(_:)), for: .touchUpInside)
        
        self.cartNotification = UILabel.init(frame: CGRect.init(x: 20, y: 2, width: 15, height: 15))
        self.cartNotification.backgroundColor = UIColor.red
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
    
    
    func styleThisBtn(btn: UIButton) {
        btn.layer.shadowColor = UIColor(red: 0, green: 178/255, blue: 186/255, alpha: 1.0).cgColor
        btn.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        btn.layer.shadowOpacity = 0.5
        btn.layer.shadowRadius = 1.0
        btn.layer.masksToBounds = false
        btn.layer.cornerRadius = 4.0
    }
    
    

}




//FOR CART TABLE
extension CartViewController: UITableViewDelegate, UITableViewDataSource, CartTableDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return  self.cartProducts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.cartTableView.dequeueReusableCell(withIdentifier: cartCellReuseIdentifier) as! CartTableViewCell
        cell.delegate = self
        cell.index = indexPath.row
        cell.productID = self.cartProducts[indexPath.row]["ID"]
        cell.titleLbl.text = self.cartProducts[indexPath.row]["product_title"]
        cell.productImage.pin_setImage(from: URL(string: self.cartProducts[indexPath.row]["product_image"]!))
        cell.priceLbl.text = Site.init().CURRENCY +  self.cartProducts[indexPath.row]["price"]!
        cell.quantityLbl.text = self.cartProducts[indexPath.row]["quantity"]
        cell.quantity = Int(self.cartProducts[indexPath.row]["quantity"]!)!
        styleThisBtn(btn: cell.increaseBtn)
        styleThisBtn(btn: cell.decreaseBtn)
//        styleThisBtn(btn: cell.removeBtn)
        
        return cell
    }
    
    func quantityUpdated(productID: String, quantity: Int, index: Int) {
//        self.cartProducts[index]["quantity"] = String(quantity)
        
        if (quantity < 1) {
            //remove row
            self.cartProducts.remove(at: index)
            let indexPath = IndexPath(item: index, section: 0)
            self.cartTableView.deleteRows(at: [indexPath], with: .fade)
            self.cartTableViewHeightC.constant = CGFloat(90 * self.cartProducts.count)
        }
        
        self.totalProgressView.isHidden = false
        self.theCart.addToCart(productID: productID, quantity: quantity, replaceQuantity: true)
    }
    
}

extension CartViewController: AddToCartDelegate {
    func cartAdded(totalItems: String, subTotal: String, total: String) {
        let totalItemsInt: Int = Int(totalItems) ?? 0
        
        let subtotalDouble: Double = Double(subTotal)!
        
        self.subtotalLbl.text = Site.init().CURRENCY + PriceFormatter.format(price: subTotal)
        //TODO: change this for another project - coupon might be added
        self.totalLbl.text = Site.init().CURRENCY + PriceFormatter.format(price: total)
        
        self.totalProgressView.isHidden = true
        
        if (subtotalDouble < 1) {
            self.completeBtn.isEnabled = false
        }
        
        if (totalItemsInt > 0) {
            self.cartNotification.text = totalItems
            self.cartNotification.isHidden = false
        } else {
            self.cartNotification.isHidden = true
        }
    }
    
    func cartNotAdded(msg: String) {
        self.view.makeToast(msg)
    }
    
    
}


extension CartViewController: PresentationDelegate {
    func dismissParent(dismiss: Bool) {
        self.dismiss(animated: false, completion: nil)
    }
    
    func presentationDismissed(action: String) {
        if (action == "present_payment") {
            let paymentViewController = PaymentViewController()
            paymentViewController.paymentDelegate = self
            self.present(paymentViewController, animated: false, completion: nil)
        }
    }

}

extension CartViewController: PaymentViewDelegate {
    func orderCreated(paymentMethod: String, status: String, checkout_url: String) {
        //present web payment
        let webPay = WebPaymentViewController()
        webPay.webPaymentDelegate = self
        webPay.url = checkout_url
        self.present(webPay, animated: false, completion: nil)
    }
}

extension CartViewController: WebPaymentDelegate {
    func paymentCanceled() {
        self.dismiss(animated: false, completion: nil)
    }
    
    
}
