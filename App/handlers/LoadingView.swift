//
//  LoadingView.swift
//  Phuck Brand
//
//  Created by Seun Oyeniyi on 12/16/21.
//  Copyright © 2021 Phuck Brand. All rights reserved.
//

import UIKit

class LoadingView: UIView {

  
}


extension UIViewController {
    struct LoaderHolder {
        static var _skyeLoadingView = LoadingView()
    }
    var skyeLoadingView: LoadingView {
        set {
            LoaderHolder._skyeLoadingView = newValue
        }
        get {
            return LoaderHolder._skyeLoadingView
        }
    }
    
    func showLoader() {
        self.view.addSubview(skyeLoadingView)
        self.skyeLoadingView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        self.skyeLoadingView.isHidden = false
    }
    func hideLoader() {
        self.skyeLoadingView.removeFromSuperview()
        self.skyeLoadingView.isHidden = true
    }
    
}
