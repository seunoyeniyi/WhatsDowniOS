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
class WebPaymentViewController: UIViewController, WKNavigationDelegate {

    @IBOutlet var webView: WKWebView!
    @IBOutlet var loadingView: UIView!
    
    var webPaymentDelegate: WebPaymentDelegate?
    
    var url: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()


        loadingView.isHidden = false
        let xurl = URL(string: url)!
        webView.load(URLRequest(url: xurl))
        webView.allowsBackForwardNavigationGestures = true
        webView.navigationDelegate = self
        
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
    
}
