//
//  ProfileAddressViewController.swift
//  Phuck Brand
//
//  Created by Seun Oyeniyi on 12/21/21.
//  Copyright © 2021 Phuck Brand. All rights reserved.
//

import UIKit
import iOSDropDown
import Alamofire
import Toast_Swift
import SwiftyJSON

class ProfileAddressViewController: UIViewController {
    
    @IBOutlet var fname: UITextField!
    @IBOutlet var lname: UITextField!
    @IBOutlet var company: UITextField!
    @IBOutlet var country: UITextField!
    @IBOutlet var state: UITextField!
    @IBOutlet var postcode: UITextField!
    @IBOutlet var city: UITextField!
    @IBOutlet var address1: UITextField!
    @IBOutlet var address2: UITextField!
    @IBOutlet var phone: UITextField!
    @IBOutlet var email: UITextField!
    @IBOutlet var saveBtn: UIButton!
    @IBOutlet var loadingView: UIView!
    
    let userSession = UserSession()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (userSession.logged()) {
            fetchAddress()
        } else {
            self.view.makeToast("Please login")
            self.dismiss(animated: true, completion: nil)
        }
        
        styleThisBtn(btn: saveBtn)
        
        self.loadingView.isHidden = false

        fetchAddress()
    }
    
    
    func fetchAddress() {
        if (!Connectivity.isConnectedToInternet) {
            self.view.makeToast("Bad Internet connection!")
            return
        }
        
        
        self.loadingView.isHidden = false
        
        let url = Site.init().USER + userSession.ID
        
        Alamofire.request(url).responseJSON { (response) -> Void in
            //check if the result has a value
            if let json_result = response.result.value {
                let json = JSON(json_result)
                let address = json["shipping_address"]
                self.fname.text = address["shipping_first_name"].stringValue
                self.lname.text = address["shipping_last_name"].stringValue
                self.company.text = address["shipping_company"].stringValue
                self.address1.text = address["shipping_address_1"].stringValue
                self.address2.text = address["shipping_address_2"].stringValue
                self.city.text = address["shipping_city"].stringValue
                self.postcode.text = address["shipping_postcode"].stringValue
                self.country.text = address["shipping_country"].stringValue
                self.state.text = address["shipping_state"].stringValue
                self.phone.text = address["shipping_phone"].stringValue
                self.email.text = address["shipping_email"].stringValue
                self.loadingView.isHidden = true
            } else {
                //no result
                self.view.makeToast("Cannot get your account! Try Again")
            }
            //after every thing
            self.loadingView.isHidden = true
        }
        
    }
    
    
    func submitDetails() {
        if (!Connectivity.isConnectedToInternet) {
            self.view.makeToast("Bad internet connection!")
            return
        }
        
        self.loadingView.isHidden = false
        
        let parameters: [String: AnyObject] = [
            "first_name": self.fname.text as AnyObject,
            "last_name": self.lname.text as AnyObject,
            "company": self.company.text as AnyObject,
            "country": self.country.text as AnyObject,
            "state": self.state.text as AnyObject,
            "city": self.city.text as AnyObject,
            "postcode": self.postcode.text as AnyObject,
            "address_1": self.address1.text as AnyObject,
            "address_2": self.address2.text as AnyObject,
            "email": self.email.text as AnyObject,
            "phone": self.phone.text as AnyObject,
            "selected_country": "" as AnyObject, //to avoid empty return
            "selected_state": "" as AnyObject, //to avoid empty return
            "shipping_provider": "" as AnyObject, //to avoid empty return
            "shipping_provider_cost": "" as AnyObject //to avoid empty return
        ]
        
        let url = Site.init().UPDATE_SHIPPING + userSession.ID;
        
        Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON {
            (response:DataResponse) in
            if let json_result = response.result.value {
                let json = JSON(json_result)
                
                if (json["code"].stringValue == "saved") {
                    self.view.makeToast("Address saved.")
                } else {
                    self.view.makeToast("Address not saved")
                }
                
            } else {
//                self.view.makeToast("Please try again!") //issue with PhuckBrand App
            }
            self.loadingView.isHidden = true
            
            
        }
        
    }
    
    
    @IBAction func saveTapped(_ sender: Any) {
        if (self.fname.text?.isEmpty)! {
            self.view.makeToast("First name is required")
            return
        }
        if (self.lname.text?.isEmpty)! {
            self.view.makeToast("Last name is required")
            return
        }
        if (self.address1.text?.isEmpty)! {
            self.view.makeToast("Address is required")
            return
        }
        if (self.address2.text?.isEmpty)! {
            self.view.makeToast("Address is required")
            return
        }
        if (self.city.text?.isEmpty)! {
            self.view.makeToast("City is required")
            return
        }
        if (self.country.text?.isEmpty)! {
            self.view.makeToast("Country is required")
            return
        }
        if (self.state.text?.isEmpty)! {
            self.view.makeToast("State is required")
            return
        }
        if (self.phone.text?.isEmpty)! {
            self.view.makeToast("Phone number is required")
            return
        }
        if (self.email.text?.isEmpty)! {
            self.view.makeToast("Email is required")
            return
        }
        
        submitDetails()
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
