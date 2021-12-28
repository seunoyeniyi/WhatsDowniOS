//
//  PaymentViewController.swift
//  Phuck Brand
//
//  Created by Seun Oyeniyi on 12/15/21.
//  Copyright © 2021 Phuck Brand. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Toast_Swift

protocol PaymentViewDelegate {
    func orderCreated(paymentMethod: String, status: String, checkout_url: String)
}

class PaymentViewController: UIViewController {
    
    var paymentDelegate: PaymentViewDelegate?
    
    @IBOutlet var apartmentLbl: UILabel!
    @IBOutlet var nameLbl: UILabel!
    @IBOutlet var houseLbl: UILabel!
    @IBOutlet var cityStateCountryLbl: UILabel!
    @IBOutlet var phoneLbl: UILabel!
    @IBOutlet var couponField: UITextField!
    @IBOutlet var couponBtn: UIButton!
    @IBOutlet var couponPriceLbl: UILabel!
    @IBOutlet var couponView: UIStackView!
    @IBOutlet var couponViewHeightC: NSLayoutConstraint! //20
    @IBOutlet var subtotalPrice: UILabel!
    @IBOutlet var totalPrice: UILabel!
    @IBOutlet var shippingTitleLbl: UILabel!
    @IBOutlet var shippingView: UIView!
    @IBOutlet var shippingViewHeightC: NSLayoutConstraint!
    
    @IBOutlet var confirmBtn: UIButton!
    @IBOutlet var flatRateBtn: UIButton!
    @IBOutlet var localPickupBtn: UIButton!
    @IBOutlet var freeShippingBtn: UIButton!
    @IBOutlet var loadingView: UIView!
    @IBOutlet var loadingViewLbl: UILabel!
    
    let userSession = UserSession()
    
    var shippingRadio: SSRadioButtonsController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.shippingRadio = SSRadioButtonsController(buttons: flatRateBtn, localPickupBtn, freeShippingBtn)
        
        styleThisBtn(btn: couponBtn)
        styleThisBtn(btn: confirmBtn)
        
        self.couponView.isHidden = true
        self.couponViewHeightC.constant = 0

        fetchAddress()
    }
    
    
    func fetchAddress() {
        if (!Connectivity.isConnectedToInternet) {
            self.view.makeToast("Bad Internet connection!")
            return
        }
        
        
        self.loadingView.isHidden = false
        
        let url = Site.init().USER + userSession.ID;
        
        Alamofire.request(url).responseJSON { (response) -> Void in
            //check if the result has a value
            if let json_result = response.result.value {
                let json = JSON(json_result)
                let address = json["shipping_address"]
                self.nameLbl.text = address["shipping_first_name"].stringValue + " " + address["shipping_last_name"].stringValue
                self.houseLbl.text = address["shipping_address_1"].stringValue
                self.apartmentLbl.text = address["shipping_address_2"].stringValue
                self.cityStateCountryLbl.text = address["shipping_city"].stringValue + " " + address["shipping_state"].stringValue + ", " + address["shipping_country"].stringValue
                self.phoneLbl.text = address["shipping_phone"].stringValue + ", " + address["shipping_email"].stringValue
                
                self.fetchCart()
            
            } else {
                //no result
                self.view.makeToast("Cannot get your account! Try Again")
                self.dismiss(animated: true, completion: nil)
            }
        }
        
    }
   
    func fetchCart() {
        if (!Connectivity.isConnectedToInternet) {
            self.view.makeToast("Bad internet connection!")
            self.dismiss(animated: true)
            return
        }
        
        self.loadingView.isHidden = false
        
        let url = Site.init().CART + userSession.ID
        
        Alamofire.request(url).responseJSON { (response) -> Void in
            //check if the result has a value
            if let json_result = response.result.value {
                let json = JSON(json_result)
                if (json["contents_count"].intValue > 0) {
                    let subtotal = json["subtotal"].doubleValue
                    let total = json["total"].doubleValue
                    
                    self.subtotalPrice.text = Site.init().CURRENCY + PriceFormatter.format(price: subtotal)
                    self.totalPrice.text = Site.init().CURRENCY + PriceFormatter.format(price: total)
                    
                    if (json["has_coupon"].stringValue == "true") {
                        let couponDiscount = json[""].doubleValue
                        self.couponViewHeightC.constant = 20
                        self.couponView.isHidden = false
                        self.couponPriceLbl.text = "-" + Site.init().CURRENCY + PriceFormatter.format(price: couponDiscount)
                    }
                    
//                    print(json)
                    
                    if (json["has_shipping"].stringValue == "true") {
                        if (json["shipping_methods"] != JSON.null) {
                            let shipping_methods = json["shipping_methods"]
                            
                            if shipping_methods["flat_rate"].exists() {
                                
                                let flat_rate = shipping_methods["flat_rate"]
                                let attributestTitle = ("<font size='4' face='Montserrat, Verdana, Geneva, sans-serif'>" + flat_rate["title"].stringValue + " <b>" + Site.init().CURRENCY + flat_rate["cost"].stringValue + "</b></font>").htmlToAttributedString
                                self.flatRateBtn.setAttributedTitle(attributestTitle, for: .normal)
                                
                            } else { self.flatRateBtn.heightAnchor.constraint(equalToConstant: CGFloat(0)); self.flatRateBtn.isHidden = true; }
                            
                            if shipping_methods["local_pickup"].exists() {
                                let local_pickup = shipping_methods["local_pickup"]
                                let attributestTitle = ("<font size='4' face='Montserrat, Verdana, Geneva, sans-serif'>" + local_pickup["title"].stringValue + " <b>" + Site.init().CURRENCY + local_pickup["cost"].stringValue + "</b></font>").htmlToAttributedString
                                self.localPickupBtn.setAttributedTitle(attributestTitle, for: .normal)
                            } else { self.localPickupBtn.heightAnchor.constraint(equalToConstant: CGFloat(0)); self.localPickupBtn.isHidden = true; }
                            
                            if shipping_methods["free_shipping"].exists() {
                                let free_shipping = shipping_methods["free_shipping"]
                                let attributestTitle = ("<font size='4' face='Montserrat, Verdana, Geneva, sans-serif'>" + free_shipping["title"].stringValue + " <b>" + Site.init().CURRENCY + free_shipping["cost"].stringValue + "</b></font>").htmlToAttributedString
                                self.freeShippingBtn.setAttributedTitle(attributestTitle, for: .normal)
                            } else { self.freeShippingBtn.heightAnchor.constraint(equalToConstant: CGFloat(0)); self.freeShippingBtn.isHidden = true; }
                            
                            self.flatRateBtn.isSelected = (json["shipping_method"].stringValue == "flat_rate")
                            self.localPickupBtn.isSelected = (json["shipping_method"].stringValue == "local_pickup")
                            self.freeShippingBtn.isSelected = (json["shipping_method"].stringValue == "free_shipping")
                            
                        } else if json["shipping_method"].stringValue == "by_printful" {
                            let attributestTitle = ("<font size='4' face='Montserrat, Verdana, Geneva, sans-serif'>Flat rate <b>" + Site.init().CURRENCY + json["shipping_cost"].stringValue + "</b></font>").htmlToAttributedString
                            self.flatRateBtn.setAttributedTitle(attributestTitle, for: .normal)
                            self.flatRateBtn.isSelected = true
                            
                            self.localPickupBtn.heightAnchor.constraint(equalToConstant: CGFloat(0)); self.localPickupBtn.isHidden = true;
                            self.freeShippingBtn.heightAnchor.constraint(equalToConstant: CGFloat(0)); self.freeShippingBtn.isHidden = true;
                            
                        } else { //no shipping methods available
                            self.shippingTitleLbl.text = "No shipping method found"
                            self.shippingView.isHidden = true
                            self.shippingViewHeightC.constant = 0
                            
                        }
                        
                        
                    } else {
                        self.shippingTitleLbl.text = "No shipping method found"
                        self.shippingView.isHidden = true
                        self.shippingViewHeightC.constant = 0
                    }
                    
                    
                } else {
                    self.view.makeToast("Empty Cart!")
                    self.dismiss(animated: true, completion: nil)
                }
                
            } else {
                //no result
                self.view.makeToast("Can't get your cart items")
                self.dismiss(animated: true, completion: nil)
                
            }
            //after every thing
            self.loadingView.isHidden = true
            
        }
        
    }
    
    func changeShippingMethod(method: String) {
        self.loadingView.isHidden = false
        
        let url = Site.init().CHANGE_CART_SHIPPING + userSession.ID + "/" + method;
        let parameters: [String: AnyObject] = [:]
        
        Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON {
            (response:DataResponse) in
            if let json_result = response.result.value {
                let json = JSON(json_result)
                
                if json["has_shipping"].stringValue == "true" {
                    
                    let subtotal = json["subtotal"].doubleValue
                    let total = json["total"].doubleValue
                    let couponDiscount = json["coupon_discount"].doubleValue
                    
                    self.subtotalPrice.text = Site.init().CURRENCY + PriceFormatter.format(price: subtotal)
                    self.totalPrice.text = Site.init().CURRENCY + PriceFormatter.format(price: total)
                    self.couponPriceLbl.text = "-" + Site.init().CURRENCY + PriceFormatter.format(price: couponDiscount)
                    
                } else {
                    self.view.makeToast("Cart has no shipping go back and update your address!")
                }
                
            } else {
                self.view.makeToast("Unable to change shipping method. Try Again")
            }
            self.loadingView.isHidden = true
        }
    }
    
    
    func applyCouponCode() {
        self.loadingView.isHidden = false
        
        let coupon: String = (self.couponField.text?.isEmpty)! ? "null" : self.couponField.text!
        
        let url = Site.init().UPDATE_COUPON + userSession.ID + "/" + coupon;
        let parameters: [String: AnyObject] = [:]
        
        Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON {
            (response:DataResponse) in
            if let json_result = response.result.value {
                let json = JSON(json_result)
                if json["has_coupon"].stringValue == "true" {
                    let subtotal = json["subtotal"].doubleValue
                    let couponDiscount = json["coupon_discount"].doubleValue
                    let total = subtotal - couponDiscount
                    
                    self.subtotalPrice.text = Site.init().CURRENCY + PriceFormatter.format(price: subtotal)
                    self.totalPrice.text = Site.init().CURRENCY + PriceFormatter.format(price: total)
                    self.couponPriceLbl.text = "-" + Site.init().CURRENCY + PriceFormatter.format(price: couponDiscount)
                    
                    self.couponViewHeightC.constant = 20
                    self.couponView.isHidden = false
                    
                    self.view.makeToast("Coupon Applied!")
                    
                } else {
                    self.view.makeToast("Invalid Coupon!")
                }
            } else {
                self.view.makeToast("Unable to apply coupon. Try Again");
            }
            self.loadingView.isHidden = true
        }
        
    }
    
    func createOrder(paymentMethod: String, status: String) {
        if (!userSession.logged()) {
            self.view.makeToast("Can't aunthenticate your loggin session!")
            self.loadingView.isHidden = true
            self.loadingViewLbl.isHidden = true
            self.loadingViewLbl.text = "Please wait..."
            return;
        }
        self.loadingView.isHidden = false
        self.loadingViewLbl.isHidden = false
        self.loadingViewLbl.text = "Creating Order..."
        
        let url = Site.init().CREATE_ORDER + userSession.ID;
    
        var parameters: [String: AnyObject] = [
            "status": status as AnyObject,
            "clear_cart": "1" as AnyObject
        ]
        if (paymentMethod != "web") {
            parameters["payment_method"] = paymentMethod as AnyObject
        }
        
        Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON {
            (response:DataResponse) in
            if let json_result = response.result.value {
                let json = JSON(json_result)
                if (json["cart_empty"].stringValue == "true" || json["cart_exists"].stringValue == "false" || !json["info"].exists()) {
                    //cannot create order because cart is empty or not found
                    self.loadingView.isHidden = true
                    self.loadingViewLbl.isHidden = true
                    self.loadingViewLbl.text = "Please wait..."
                    
                    let alert = UIAlertController(title: "Alert", message: "Cannot create order because cart is empty or not found.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                        switch action.style {
                        case .default:
                            alert.dismiss(animated: true, completion: nil)
                        case .cancel:
                            alert.dismiss(animated: true, completion: nil)
                        case .destructive:
                            alert.dismiss(animated: true, completion: nil)
                        }
                    }))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    //order created
                    self.userSession.update_last_orders_count(count: String(Int(self.userSession.last_orders_count)! + 1));
                    //since order is currently a webview
                    let info = json["info"]
                    var checkout_url = info["checkout_payment_url"].stringValue
                    checkout_url += "&sk-web-payment=1&sk-browser=1&sk-user-checkout=" + self.userSession.ID;
                    //go to browser
                    self.dismiss(animated: false, completion: {
                        self.paymentDelegate?.orderCreated(paymentMethod: paymentMethod, status: status, checkout_url: checkout_url)
                    })
                }
                
            } else {
                self.view.makeToast("Unable to complete your order. Please contact us OR Try Again!")
                self.loadingView.isHidden = true
                self.loadingViewLbl.isHidden = true
                self.loadingViewLbl.text = "Please wait..."
            }
            
        }
        
    }
    
    @IBAction func confirmTapped(_ sender: Any) {
        createOrder(paymentMethod: "web", status: "pending")
    }
    
    
    @IBAction func flateRateTapped(_ sender: Any) {
        changeShippingMethod(method: "flat_rate")
    }
    @IBAction func localPickupTapped(_ sender: Any) {
        changeShippingMethod(method: "local_pickup")
    }
    @IBAction func freeShippingTapped(_ sender: Any) {
        changeShippingMethod(method: "free_shipping")
    }
    
    @IBAction func applyCouponTapped(_ sender: Any) {
        self.applyCouponCode()
    }
    
    
    @IBAction func backTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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


