//
//  BrowserViewController.swift
//  Phuck Brand
//
//  Created by Seun Oyeniyi on 12/21/21.
//  Copyright © 2021 Phuck Brand. All rights reserved.
//

import UIKit
import WebKit

class BrowserViewController: UIViewController, WKNavigationDelegate {
    
    @IBOutlet var theNavigationItem: UINavigationItem!
    @IBOutlet var webView: WKWebView!
    @IBOutlet var loadingView: UIView!
    
    var headTitle: String = ""
    var url: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        theNavigationItem.title = headTitle
        
        loadingView.isHidden = false
        let xurl = URL(string: url)!
        webView.load(URLRequest(url: xurl))
        webView.allowsBackForwardNavigationGestures = true
        webView.navigationDelegate = self
        
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        loadingView.isHidden = false
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadingView.isHidden = true
    }


    @IBAction func backTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
