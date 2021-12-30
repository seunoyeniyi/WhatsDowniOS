//
//  OrderViewController.swift
//  Phuck Brand
//
//  Created by Seun Oyeniyi on 12/21/21.
//  Copyright © 2021 Phuck Brand. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Toast_Swift

class OrderViewController: UIViewController {

    @IBOutlet var theNavigationItem: UINavigationItem!
    @IBOutlet var loadingView: UIView!
    @IBOutlet var loadingActivity: UIActivityIndicatorView!
    @IBOutlet var errorLabel: UILabel!
    @IBOutlet var tryAgainBtn: UIButton!
    @IBOutlet var payNowBtn: UIButton!
    @IBOutlet var payNowBtnHeightC: NSLayoutConstraint! //40
    @IBOutlet var processInfo: UILabel!
    @IBOutlet var itemsTableView: UITableView!
    @IBOutlet var itemsTableViewHeightC: NSLayoutConstraint!
    @IBOutlet var subtotalLbl: UILabel!
    @IBOutlet var discountLbl: UILabel!
    @IBOutlet var shippingLbl: UILabel!
    @IBOutlet var totalLbl: UILabel!
    @IBOutlet var email: UILabel!
    @IBOutlet var fullName: UILabel!
    @IBOutlet var company: UILabel!
    @IBOutlet var address1: UILabel!
    @IBOutlet var address2: UILabel!
    @IBOutlet var city: UILabel!
    @IBOutlet var state: UILabel!
    @IBOutlet var postcode: UILabel!
    @IBOutlet var country: UILabel!
    @IBOutlet var phone: UILabel!
    
    
    var orderID: String = "0"
    var index: Int!
    
    var checkout_url: String = ""
    
    let userSession = UserSession()
    
    let itemsCellReuseIdentifier = "OrderItemsTableViewCell"
    
    var items: Array<Dictionary<String, String>> = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        theNavigationItem.title = "Order #" + orderID
        
        let itemsCell = UINib(nibName: itemsCellReuseIdentifier, bundle: nil)
        self.itemsTableView.register(itemsCell, forCellReuseIdentifier: itemsCellReuseIdentifier)
        self.itemsTableView.tableFooterView = UIView()//to remove the extra empty cell divider lines
        
        self.itemsTableView.delegate = self
        self.itemsTableView.dataSource = self
        
        circleStyleThisBtn(btn: payNowBtn)

     fetchOrder()
    }
    
    func fetchOrder() {
        if (!Connectivity.isConnectedToInternet) {
            self.view.makeToast("Bad internet connection!")
            self.loadingView.isHidden = false
            self.loadingActivity.isHidden = true
            self.errorLabel.isHidden = false
            self.tryAgainBtn.isHidden = false
            return
        }
        
        self.loadingView.isHidden = false
        self.loadingActivity.isHidden = false
        self.errorLabel.isHidden = true
        self.tryAgainBtn.isHidden = true
        
        let url = Site.init().ORDER + self.orderID + "/" + userSession.ID;
        
        Alamofire.request(url).responseJSON { (response) -> Void in
            //check if the result has a value
            if let json_result = response.result.value {
                let json = JSON(json_result)
//                print(json)
                if (json["code"].exists() && json["data"] == JSON.null) {
                    self.view.makeToast(json["message"].stringValue)
                    self.loadingView.isHidden = false
                    self.loadingActivity.isHidden = true
                    self.errorLabel.isHidden = false
                    self.tryAgainBtn.isHidden = false
                } else {
                    var statusText = "Unknown status"
                    switch (json["status"].stringValue) {
                    case "pending":
                        statusText = "Pending payment";
                        break;
                    case "processing":
                        statusText = "Processing";
                        break;
                    case "completed":
                        statusText = "Completed";
                        break;
                    case "on-hold":
                        statusText = "On hold";
                        break;
                    case "cancelled":
                        statusText = "Cancelled";
                        break;
                    case "refunded":
                        statusText = "Refunded";
                        break;
                    default:
                        break;
                    }
                    if (json["payment_method"] == ["paypal"] && json["status"] == "on-hold") {
                        statusText = "Paypal Cancelled";
                    }
                    
                    self.processInfo.text = "Order #" + json["ID"].stringValue + " was placed on " + json["date_modified_date"].stringValue + " and is currently " + statusText + "."
                    
                    
                    //FOR RE-PAYMENT OF pending orders
                    if json["status"] == "pending" {
                        self.checkout_url = json["checkout_payment_url"].stringValue
                        if (json["payment_method"] == "stripe_cc" || json["payment_method"] == "stripe") {
                            self.checkout_url += "&sk-web-payment=1&sk-stripe-checkout=1&sk-user-checkout=" + self.userSession.ID; //for stripe only
                            self.checkout_url += "&in_sk_app=1"
                            self.checkout_url += "&hide_elements=div*topbar.topbar, div.joinchat__button"
                        } else {
                            self.checkout_url += "&sk-web-payment=1&sk-user-checkout=" + self.userSession.ID; //for any payment method
                            self.checkout_url += "&in_sk_app=1"
                            self.checkout_url += "&hide_elements=div*topbar.topbar, div.joinchat__button"
                        }
                        self.payNowBtnHeightC.constant = 40
                        self.payNowBtn.isHidden = false
                    } else {
                        self.payNowBtnHeightC.constant = 0
                        self.payNowBtn.isHidden = true
                    }
                    
                    //get items
                    let products = json["products"]
                    self.items = []
                    for (_, product): (String, JSON) in products {
                        self.items.append([
                            "name": product["name"].stringValue,
                            "quantity": product["quantity"].stringValue,
                            "subtotal": product["subtotal"].stringValue
                            ])
                    }
                    
                    DispatchQueue.main.async {
                        self.itemsTableView.reloadData()
                        self.itemsTableViewHeightC.constant = CGFloat(53 * self.items.count)
                    }
                    
                    //set neccassary labels
                    self.subtotalLbl.text = Site.init().CURRENCY + PriceFormatter.format(price: json["subtotal"].doubleValue)
                    let subtotalDouble = json["subtotal"].doubleValue
                    let totalDouble = json["total"].doubleValue
                    let discountTotal = totalDouble - subtotalDouble
                    
                    self.discountLbl.text = Site.init().CURRENCY + PriceFormatter.format(price: (discountTotal < 0) ? discountTotal : 0) //if discount is negative only
                    self.shippingLbl.attributedText = ("<font size='3' face='Verdana, Geneva, sans-serif'>" + json["shipping_to_display"].stringValue + "</font>").htmlToAttributedString
                    self.totalLbl.text = Site.init().CURRENCY + PriceFormatter.format(price: json["total"].doubleValue)
                    //set shipping address info
                    self.fullName.text = json["shipping_first_name"].stringValue + " " + json["shipping_last_name"].stringValue;
                    self.company.text = json["shipping_company"].stringValue
                    self.address1.text = json["shipping_address_1"].stringValue
                    self.address2.text = json["shipping_address_2"].stringValue
                    self.city.text = json["shipping_city"].stringValue
                    self.state.text = json["shipping_state"].stringValue
                    self.postcode.text = json["shipping_postcode"].stringValue
                    self.country.text = json["shipping_country"].stringValue
                    self.phone.text = json["billing_phone"].stringValue //shipping does not have phone
                    self.email.text = json["billing_email"].stringValue //shipping does not have email
                    
                    
                    
                    self.loadingView.isHidden = true
                }
    
            } else {
                self.view.makeToast("Unable to get order")
                self.loadingView.isHidden = false
                self.loadingActivity.isHidden = true
                self.errorLabel.isHidden = false
                self.tryAgainBtn.isHidden = false
            }
        }
        
        
    }
    @IBAction func payNowTapped(_ sender: Any) {
        let webPay = WebPaymentViewController()
        webPay.webPaymentDelegate = self
        webPay.url = self.checkout_url
        self.present(webPay, animated: true, completion: nil)
    }
    
    @IBAction func tryAgainTapped(_ sender: Any) {
        fetchOrder()
    }
    @IBAction func backTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func circleStyleThisBtn(btn: UIButton) {
        btn.layer.shadowColor = UIColor(red: 0, green: 178/255, blue: 186/255, alpha: 1.0).cgColor
        btn.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        btn.layer.shadowOpacity = 0.5
        btn.layer.shadowRadius = 1.0
        btn.layer.masksToBounds = false
        btn.layer.cornerRadius = 20.0
    }
    
}

extension OrderViewController: WebPaymentDelegate {
    func paymentCanceled() {
        self.fetchOrder()
    }
}

extension OrderViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.itemsTableView.dequeueReusableCell(withIdentifier: self.itemsCellReuseIdentifier) as! OrderItemsTableViewCell
        cell.quantity.text = self.items[indexPath.row]["quantity"]!
        cell.title.text = self.items[indexPath.row]["name"]!
        cell.price.text = Site.init().CURRENCY + PriceFormatter.format(price: self.items[indexPath.row]["subtotal"]!)
        
        return cell
    }

}

