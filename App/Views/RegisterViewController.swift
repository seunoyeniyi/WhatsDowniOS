//
//  RegisterViewController.swift
//  Phuck Brand
//
//  Created by Seun Oyeniyi on 11/6/21.
//  Copyright © 2021 Phuck Brand. All rights reserved.
//

import UIKit
import Alamofire
import Toast_Swift
import SwiftyJSON

class RegisterViewController: UIViewController {
    @IBOutlet var registerBtn: UIButton!
    @IBOutlet var walletField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var emailField: UITextField!
    @IBOutlet var usernameField: UITextField!
    
    
    let userSession = UserSession()
    var onDoneBlock : ((Bool) -> Void)?
    

    override func viewDidLoad() {
        super.viewDidLoad()

        styleThisBtn(btn: registerBtn)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func registerTapped(_ sender: Any) {
        if !Connectivity.isConnectedToInternet {
            self.view.makeToast("Please check your internet connection!")
            return
        }
        
        
        let username = usernameField.text
        let email = emailField.text
        let password = passwordField.text
        let wallet = walletField.text
        
        if ((username?.count)! < 2) {
            self.view.makeToast("Username or email required!")
            return
        }
        if ((email?.count)! < 2) {
            self.view.makeToast("Email required!")
            return
        }
        if ((password?.count)! < 2) {
            self.view.makeToast("Password required!")
            return
        }
        
        
        let activityViewController = ActivityViewController(message: "Please wait...")
        present(activityViewController, animated: true, completion: nil)
        
        let url: String = Site.init().REGISTER;
        var parameters: [String: AnyObject] = [
            "username" : username as AnyObject,
            "email" : email as AnyObject,
            "password" : password as AnyObject,
            "tron_wallet" : wallet as AnyObject
        ]
        if (userSession.ID != "0") { //ID maybe hash code for anonymoush user
            parameters["replace_cart_user"] = userSession.ID as AnyObject
        }
        
        Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON {
            (response:DataResponse) in
            if let json_result = response.result.value {
                let json = JSON(json_result)
//                print(json)
                if json["code"].exists() || json["data"] == JSON.null {
                    activityViewController.dismiss(animated: false, completion: nil)
                    if json["message"].exists() {
                        self.view.makeToast(json["message"].stringValue)
                    } else {
                        self.view.makeToast("Unable to get you registered at the moment!")
                    }
                } else {
                    let data = json["data"]
                    //save user session
                    let id = data["ID"].stringValue
                    self.userSession.createLoginSession(userID: id, xusername: data["user_login"].stringValue, xemail: data["user_email"].stringValue, logged: true)
                    self.view.makeToast("Registration Completed... Welcome!")
                    self.userSession.reload()
                    activityViewController.dismiss(animated: false, completion: nil)
                    
                    self.dismiss(animated: true, completion: nil)
                    self.onDoneBlock!(true)
                    //                    print(data)
                }
            } else {
                activityViewController.dismiss(animated: false, completion: nil)
                self.view.makeToast("Unable to get you registered at the moment!")
            }
        }
    }
    @IBAction func loginTapped(_ sender: Any) {
        self.onDoneBlock!(false)
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func cancelTapped(_ sender: Any) {
        self.onDoneBlock!(false)
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func styleThisBtn(btn: UIButton) {
        btn.layer.shadowColor = UIColor(red: 0, green: 178/255, blue: 186/255, alpha: 1.0).cgColor
        btn.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        btn.layer.shadowOpacity = 0.5
        btn.layer.shadowRadius = 1.0
        btn.layer.masksToBounds = false
        btn.layer.cornerRadius = 4.0
    }

}
