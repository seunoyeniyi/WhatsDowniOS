//
//  CheckoutAddressViewController.swift
//  Phuck Brand
//
//  Created by Seun Oyeniyi on 12/11/21.
//  Copyright © 2021 Phuck Brand. All rights reserved.
//

import UIKit
import iOSDropDown
import Toast_Swift
import Alamofire
import SwiftyJSON

class CheckoutAddressViewController: UIViewController {
    
    var presentationDelegate: PresentationDelegate?

    @IBOutlet var firstName: UITextField!
    @IBOutlet var lastName: UITextField!
    @IBOutlet var company: UITextField!
    @IBOutlet var country: DropDown!
    @IBOutlet var state: DropDown!
    @IBOutlet var postCode: UITextField!
    @IBOutlet var city: UITextField!
    @IBOutlet var address1: UITextField!
    @IBOutlet var address2: UITextField!
    @IBOutlet var phoneNumber: UITextField!
    @IBOutlet var email: UITextField!
    @IBOutlet var proceedBtn: UIButton!
    @IBOutlet var loadingView: UIView!
    

    
    var countries: Array<Dictionary<String, String>> = [] //code and name
    var countryStates: Array<Dictionary<String, String>> = [] //code and name
    var states: Array<Dictionary<String, Any>> = [] //country code and its states
    var countriesString: Array<String> = []
    var statesString: Array<String> = []
    var selectedCountry: String = ""
    var selectedState: String = ""
    
    var cartItems: Array<Dictionary<String, AnyObject>> = []
    
    let PRINTFUL_USERNAME = "0l3nyy70-vek2-q763";
    let PRINTFUL_PASSWORD = "6gcs-twusmi63y8tz";
 
    let userSession = UserSession()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getCart()
       
        if (userSession.logged()) {
             fetchAddress()
        } else {
            self.view.makeToast("Please login")
            self.dismiss(animated: true, completion: nil)
        }
        

        country.didSelect{(selectedText, index, id) in
            self.selectedCountry = self.countries[index]["code"]!
            self.state.text = ""
            self.countryStates = self.getCountryStates(countryCode: self.selectedCountry, states: self.states)
            self.statesString = []
            for (_, state) in self.countryStates.enumerated() {
                self.statesString.append(state["name"]!)
            }
            self.state.optionArray = self.statesString
        }
        state.didSelect{(selectedText, index, id) in
            self.selectedState = self.countryStates[index]["code"]!
        }
        
        styleThisBtn(btn: proceedBtn)

    }
    
    func getCountryStates(countryCode: String, states: Array<Dictionary<String, Any>>) -> Array<Dictionary<String, String>> {
  
        for (_, countryStates) in states.enumerated() {
            if (countryStates["code"] as? String == countryCode) {
                return countryStates["states"] as! Array<Dictionary<String, String>>
            }
        }
        return [];
    }
    
    func fetchAddress() {
        if (!Connectivity.isConnectedToInternet) {
            self.view.makeToast("Bad Internet connection!")
            return
        }
        
        
        self.loadingView.isHidden = false
    
        let url = Site.init().USER + userSession.ID + "?with_regions=1"
        
        Alamofire.request(url).responseJSON { (response) -> Void in
            //check if the result has a value
            if let json_result = response.result.value {
                let json = JSON(json_result)
                let address = json["shipping_address"]
                self.firstName.text = address["shipping_first_name"].stringValue
                self.lastName.text = address["shipping_last_name"].stringValue
                self.company.text = address["shipping_company"].stringValue
                self.address1.text = address["shipping_address_1"].stringValue
                self.address2.text = address["shipping_address_2"].stringValue
                self.city.text = address["shipping_city"].stringValue
                self.postCode.text = address["shipping_postcode"].stringValue
                self.country.text = address["shipping_country"].stringValue
                self.state.text = address["shipping_state"].stringValue
                self.phoneNumber.text = address["shipping_phone"].stringValue
                self.email.text = address["shipping_email"].stringValue
                
                let regions = json["regions"]
                let countriesObj = regions["countries"]
                let statesObj = regions["states"]
                
                //countries
                self.countries = []
                self.countriesString = []
                for (code, name): (String, JSON) in countriesObj {
                    
                    if (code == address["shipping_country"].stringValue || name.stringValue == address["shipping_country"].stringValue) { self.selectedCountry = code }
                    
                    self.countries.append([
                        "code": code,
                        "name": name.stringValue
                        ])
                    self.countriesString.append(name.stringValue)
                }
                self.country.optionArray = self.countriesString
                
                //states
                self.states = []
                self.countryStates = []
                self.statesString = []
                for (code, states): (String, JSON) in statesObj {
                    var theCountryStates: Array<Dictionary<String, String>> = []
                    for (stateCode, name): (String, JSON) in states {
                        theCountryStates.append([
                            "code": stateCode,
                            "name": name.stringValue
                            ])
                        if (stateCode == self.selectedState || name.stringValue == self.selectedState) { //since selectedCountry might have been set above
                            if (stateCode == address["shipping_state"].stringValue || name.stringValue == address["shipping_state"].stringValue) { self.selectedState = stateCode }
                            
                        }
                    }
                    self.states.append([
                        "code": code,
                        "states": theCountryStates
                        ])
                    
                }
                self.countryStates = self.getCountryStates(countryCode: self.selectedCountry, states: self.states)
                for (_, state) in self.countryStates.enumerated() {
                    self.statesString.append(state["name"]!)
                }
                self.state.optionArray = self.statesString
                
                
               
            } else {
                //no result
             self.view.makeToast("Cannot get your account! Try Again")
            }
            //after every thing
            self.loadingView.isHidden = true
        }
        
    }
    
    

    @IBAction func proceedTapped(_ sender: Any) {
        if (self.firstName.text?.isEmpty)! {
            self.view.makeToast("First name is required")
            return
        }
        if (self.lastName.text?.isEmpty)! {
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
        if (self.phoneNumber.text?.isEmpty)! {
            self.view.makeToast("Phone number is required")
            return
        }
        if (self.email.text?.isEmpty)! {
            self.view.makeToast("Email is required")
            return
        }
        
        submitDetails()
        
        
    }
    
    func getCart() {
        if (!Connectivity.isConnectedToInternet) {
            self.view.makeToast("Bad internet connection!")
            return
        }
        let url = Site.init().CART + userSession.ID
        
        Alamofire.request(url).responseJSON { (response) -> Void in
            //check if the result has a value
            if let json_result = response.result.value {
                let json = JSON(json_result)
                if (json["contents_count"].intValue > 0) {
                    if (json["items"].exists()) {
                        let items = json["items"]
                        self.cartItems = []
                        for (_, item): (String, JSON) in items {
                            self.cartItems.append([
                                "variant_id": item["ID"].stringValue as AnyObject,
                                "quantity": item["quantity"].stringValue as AnyObject
                                ])
                        }
                    }
                    
                } else {
                    self.view.makeToast("Cart empty!")
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    
    func submitDetails() {
        self.loadingView.isHidden = false
        
        let parameters: [String: AnyObject] = [
            "first_name": self.firstName.text as AnyObject,
            "last_name": self.lastName.text as AnyObject,
            "company": self.company.text as AnyObject,
            "country": self.country.text as AnyObject,
            "state": self.state.text as AnyObject,
            "city": self.city.text as AnyObject,
            "postcode": self.postCode.text as AnyObject,
            "address_1": self.address1.text as AnyObject,
            "address_2": self.address2.text as AnyObject,
            "email": self.email.text as AnyObject,
            "phone": self.phoneNumber.text as AnyObject,
//            "selected_country": self.selectedCountry as AnyObject,
//            "selected_state": self.selectedState as AnyObject,
     
        ]
        
        let url = Site.init().UPDATE_SHIPPING + userSession.ID;
        
        Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON {
            (response:DataResponse) in
            if let json_result = response.result.value {
                let json = JSON(json_result)
                
                if (json["code"].stringValue == "saved") {
                    self.dismiss(animated: true, completion: {
                        self.presentationDelegate?.presentationDismissed(action: "present_payment")
                    })
                } else {
                    self.view.makeToast("Address not saved")
                    self.loadingView.isHidden = true
                }
                
            } else {
                self.view.makeToast("Please try again!")
                self.loadingView.isHidden = true
            }
            
            
        }
        
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
