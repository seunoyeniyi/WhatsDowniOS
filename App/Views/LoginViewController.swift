//
//  LoginViewController.swift
//  Phuck Brand
//
//  Created by Seun Oyeniyi on 11/6/21.
//  Copyright © 2021 Phuck Brand. All rights reserved.
//

import UIKit
import Alamofire
import Toast_Swift
import SwiftyJSON

protocol LoginDelegate {
    func onLoginDone(logged: Bool)
}
class LoginViewController: UIViewController {
    
    var delegate: LoginDelegate?
    
    @IBOutlet var loginBtn: UIButton!
    @IBOutlet var registerBtn: UIButton!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var usernameField: UITextField!
    
    
    let userSession = UserSession()
    let registerViewController = RegisterViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        styleThisBtn(btn: loginBtn)
        
        registerViewController.delegate = self
        
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        
        if !Connectivity.isConnectedToInternet {
            self.view.makeToast("Please check your internet connection!")
            return
        }
        
        
        let username = usernameField.text
        let password = passwordField.text
        
        if ((username?.count)! < 2) {
            self.view.makeToast("Username or email required!")
            return
        }
        if ((password?.count)! < 2) {
            self.view.makeToast("Password required!")
            return
        }
        
        
        let activityViewController = ActivityViewController(message: "Please wait...")
        present(activityViewController, animated: true, completion: nil)
        
        let url: String = Site.init().LOGIN;
        var parameters: [String: AnyObject] = [
            "username" : username as AnyObject,
            "password" : password as AnyObject
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
                    self.view.makeToast("Incorrect login details!")
                } else {
                    let data = json["data"]
                    //save user session
                    self.userSession.createLoginSession(userID: json["ID"].stringValue, xusername: data["user_login"].stringValue, xemail: data["user_email"].stringValue, logged: true)
                    self.view.makeToast("Welcome Back!")
                    self.userSession.reload()
                    activityViewController.dismiss(animated: false, completion: nil)
                    self.dismiss(animated: true, completion: {
                        if let delegate = self.delegate {
                            delegate.onLoginDone(logged: true)
                        }
                    })
//                    print(data)
                }
            } else {
                activityViewController.dismiss(animated: false, completion: nil)
                self.view.makeToast("Unable to get you logged!")
            }
        }
        
    }
    
    
    
    @IBAction func registerTapped(_ sender: Any) {
        self.present(registerViewController, animated: true)
    }
    
    
    @IBAction func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            if let delegate = self.delegate {
                delegate.onLoginDone(logged: false)
            }
        })
    }
    
    
    
    func styleThisBtn(btn: UIButton) {
        btn.layer.shadowColor = UIColor(red: 0, green: 178/255, blue: 186/255, alpha: 1.0).cgColor
        btn.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        btn.layer.shadowOpacity = 0.5
        btn.layer.shadowRadius = 1.0
        btn.layer.masksToBounds = false
        btn.layer.cornerRadius = 4.0
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
extension LoginViewController: RegisterDelegate {
    func onRegistrationDone(registered: Bool) {
        if registered {
            
            self.dismiss(animated: false, completion: {
                if let delegate = self.delegate {
                    delegate.onLoginDone(logged: true)
                }
                
            })
        }
    }
}
