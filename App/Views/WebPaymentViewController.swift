//
//  WebPaymentViewController.swift
//  Phuck Brand
//
//  Created by Seun Oyeniyi on 12/17/21.
//  Copyright © 2021 Phuck Brand. All rights reserved.
//

import UIKit
import WebKit

protocol WebPaymentDelegate {
    func paymentCanceled()
}
class WebPaymentViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler {
    
    
    @IBOutlet var containerView: UIView!
    @IBOutlet var webView: WKWebView!
    @IBOutlet var loadingView: UIView!
    @IBOutlet var orderPlacedView: UIView!
    @IBOutlet var continueBtn: UIButton!
    
    var webPaymentDelegate: WebPaymentDelegate?
    
    var url: String!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        orderPlacedView.isHidden = true
        
        
                let contentController = WKUserContentController()
                contentController.add(self, name: "skyeHandler")
        
        
                let preferences = WKPreferences()
                preferences.javaScriptEnabled = true;
                preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
                let configuration = WKWebViewConfiguration()
                configuration.preferences = preferences
                configuration.userContentController = contentController
        
        
        webView = WKWebView(frame: .zero, configuration: configuration)
                webView.navigationDelegate = self
        
        
        containerView.addSubview(webView)
        webView.frame = CGRect(x: 0, y: 0, width: containerView.frame.width, height: containerView.frame.height + 50)

        loadingView.isHidden = false
        let encode: String = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        let xurl: URL = URL(string: encode)!
        webView.load(URLRequest(url: xurl))
        webView.allowsBackForwardNavigationGestures = true
        webView.navigationDelegate = self
        
    }
    
    
    @IBAction func continueBtnTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        self.webPaymentDelegate?.paymentCanceled()
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        self.webPaymentDelegate?.paymentCanceled()
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        loadingView.isHidden = false
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadingView.isHidden = true
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if (message.name == "skyeHandler") {
            //show order placed
            self.orderPlacedView.isHidden = false
        }
    }
    
}





