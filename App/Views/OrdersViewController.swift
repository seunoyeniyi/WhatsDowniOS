//
//  OrdersViewController.swift
//  Phuck Brand
//
//  Created by Seun Oyeniyi on 12/20/21.
//  Copyright © 2021 Phuck Brand. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Toast_Swift
import iOSDropDown

class OrdersViewController: UIViewController {
    @IBOutlet var theNavigationItem: UINavigationItem!
    @IBOutlet var anyErrorView: UIView!
    @IBOutlet var errorLabel: UILabel!
    @IBOutlet var tryAgainBtn: UIButton!
    @IBOutlet var loadingView: UIView!
    @IBOutlet var ordersTableView: UITableView!
    @IBOutlet var statusDropDown: DropDown!
    
    
    let userSession = UserSession()
    
    let ordersCellReuseIdentifier = "OrdersTableViewCell"
    
    var orders: Array<Dictionary<String, String>> = []
    var orderStatus: String = "all"
    
    
    let statuses: Array<String> = [
        "all",
        "completed",
        "processing",
        "pending"
    ]
    let statusesString: Array<String> = [
        "All",
        "Completed",
        "Processing",
        "Pending "
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        statusDropDown.optionArray = statusesString
        statusDropDown.isSearchEnable = false
        
        switch orderStatus {
        case "complete", "completed", "wc-completed":
            self.theNavigationItem.title = "Completed Orders"
            self.statusDropDown.text = self.statusesString[1]
        case "processing", "wc-processing":
            self.theNavigationItem.title = "Processing Orders"
            self.statusDropDown.text = self.statusesString[2]
        case "pending", "wc-pending":
            self.theNavigationItem.title = "Pending Orders"
            self.statusDropDown.text = self.statusesString[3]
        default:
            self.theNavigationItem.title = "Orders"
            self.statusDropDown.text = self.statusesString[0]
        }
        
        let ordersCell = UINib(nibName: ordersCellReuseIdentifier, bundle: nil)
        self.ordersTableView.register(ordersCell, forCellReuseIdentifier: ordersCellReuseIdentifier)
        self.ordersTableView.tableFooterView = UIView()//to remove the extra empty cell divider lines
        
        self.ordersTableView.delegate = self
        self.ordersTableView.dataSource = self
        
        styleThisBtn(btn: tryAgainBtn)
        
        statusDropDown.didSelect{(selectedText, index, id) in
            self.orderStatus = self.statuses[index]
            self.fetchOrders()
        }

        fetchOrders()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    
    func fetchOrders() {
        if (!Connectivity.isConnectedToInternet) {
            self.view.makeToast("Bad internet connection!")
            self.anyErrorView.isHidden = false
            self.loadingView.isHidden = true
            return
        }
        
        self.loadingView.isHidden = false
        self.anyErrorView.isHidden = true
        
       
        
        var url = Site.init().ORDERS + userSession.ID;
        switch self.orderStatus {
        case "complete", "completed", "wc-completed":
            url = Site.init().ORDERS + userSession.ID + "?status=wc-completed";
        case "processing", "wc-processing":
            url = Site.init().ORDERS + userSession.ID + "?status=wc-processing";
        case "pending", "wc-pending":
            url = Site.init().ORDERS + userSession.ID + "?status=wc-pending";
        case "on-hold", "wc-on-hold":
            url = Site.init().ORDERS + userSession.ID + "?status=wc-on-hold";
        default:
            break
        }
        
        Alamofire.request(url).responseJSON { (response) -> Void in
            //check if the result has a value
            if let json_result = response.result.value {
                let json = JSON(json_result)
//                print(json)
                let orders = json["orders"]
                if orders.count > 0 {
                    self.orders = []
                    for (_, order): (String, JSON) in orders {
                        self.orders.append([
                            "ID": order["ID"].stringValue,
                            "date_modified_date": order["date_modified_date"].stringValue,
                            "status": order["status"].stringValue,
                            "total": order["total"].stringValue,
                            "item_count": order["item_count"].stringValue,
                            "payment_method": order["payment_method"].stringValue
                            ])
                    }
                    
                    DispatchQueue.main.async {
                        self.ordersTableView.reloadData()
//                        self.ordersTableViewHeightC.constant = CGFloat(130 * self.orders.count)
                    }
                    
                    
                } else {
                    self.anyErrorView.isHidden = false
                }
                
                
                
            } else {
             self.anyErrorView.isHidden = false
            }
            self.loadingView.isHidden = true
        }
    }
    
    
    @IBAction func backTapped(_ sender: Any) {
        if (self.isModal) {
            self.dismiss(animated: false, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    @IBAction func tryAgainTapped(_ sender: Any) {
        fetchOrders()
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

extension OrdersViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.orders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.ordersTableView.dequeueReusableCell(withIdentifier: ordersCellReuseIdentifier) as! OrdersTableViewCell
        cell.orderID.text = "#" + self.orders[indexPath.row]["ID"]!
        cell.orderDate.text = self.orders[indexPath.row]["date_modified_date"]!
        cell.orderPaymentMethod.text = Site.init().payment_method_title(slug: self.orders[indexPath.row]["payment_method"]!)
        cell.orderTotalPrice.text = Site.init().CURRENCY + PriceFormatter.format(price: self.orders[indexPath.row]["total"]!)
        
        if (self.orders[indexPath.row]["status"]! == "processing" || self.orders[indexPath.row]["status"]! == "completed") {
            cell.orderStatusImg.image = UIImage(named: "icons8_checked")
        } else {
            cell.orderStatusImg.image = UIImage(named: "icons8_data_pending_1")
        }
        if (self.orders[indexPath.row]["status"]! != "completed" && self.orders[indexPath.row]["payment_method"]! == "cod") {
            cell.orderStatusImg.image = UIImage(named: "icons8_data_pending_1")
        }
        if (self.orders[indexPath.row]["payment_method"]! == "paypal" && self.orders[indexPath.row]["status"]! == "on-hold") {
            cell.orderStatusImg.image = UIImage(named: "icons8_cancel")
        }
        

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let orderPage = OrderViewController()
        orderPage.orderID = self.orders[indexPath.row]["ID"]!
        orderPage.index = indexPath.row
        
        self.present(orderPage, animated: true, completion: nil)
    }
    
    
}
