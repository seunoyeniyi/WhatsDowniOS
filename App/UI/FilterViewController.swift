//
//  FilterViewController.swift
//  WhatsDown
//
//  Created by Seun Oyeniyi on 12/26/21.
//  Copyright © 2021 Phuck Brand. All rights reserved.
//

import UIKit
import WARangeSlider
import iOSDropDown
import Alamofire
import SwiftyJSON

protocol FilterDelegate {
    func onFilterSubmit(category: String, tag: String, priceRange: Array<String>)
}

class FilterViewController: UIViewController {
    
    var delegate: FilterDelegate?
   
    @IBOutlet var cateogryDropDown: DropDown!
    @IBOutlet var sliderViewContainer: UIView!
    @IBOutlet var priceRangeLbl: UILabel!
    @IBOutlet var tagDropDown: DropDown!
    @IBOutlet var categoryActivity: UIActivityIndicatorView!
    @IBOutlet var tagActivity: UIActivityIndicatorView!
    
    
    let priceSlider = RangeSlider()
    let maximumPrice = 15000.0
    let initialLower = 1000.0
    let initialUpper = 14000.0
    
    var categories: Array<Dictionary<String, String>> = []
    var categoriesString: Array<String> = []
    var tags: Array<Dictionary<String, String>> = []
    var tagsString: Array<String> = []
    
    var selected_category = ""
    var selected_tag = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        priceRangeLbl.text = Site.init().CURRENCY + PriceFormatter.format(price: initialLower) + "  - " + Site.init().CURRENCY + PriceFormatter.format(price: initialUpper)

        priceSlider.frame = CGRect(x: 0, y: 0, width: sliderViewContainer.frame.width, height: sliderViewContainer.frame.height)
        priceSlider.minimumValue = 0.0
        priceSlider.maximumValue = maximumPrice
        priceSlider.lowerValue = initialLower
        priceSlider.upperValue = initialUpper
        priceSlider.trackHighlightTintColor = UIColor(named: "Primary")!
        priceSlider.thumbTintColor = UIColor(named: "Primary")!
        priceSlider.thumbBorderColor = UIColor(named: "Primary")!
        sliderViewContainer.addSubview(priceSlider)
        
        priceSlider.addTarget(self, action: #selector(self.priceSliderValueChanged(_:)), for: .valueChanged)
        
        cateogryDropDown.didSelect{(selectedText, index, id) in
            self.selected_category = self.categories[index]["slug"]!
        }
        tagDropDown.didSelect{(selectedText, index, id) in
            self.selected_tag = self.tags[index]["slug"]!
        }
        
       fetchCategories()
        fetchTags()
    }
    
    func fetchCategories() {
        
        self.categoryActivity.isHidden = false
        
        let url = Site.init().CATEGORIES + "?hide_empty=1&order_by=menu_order";
        
        Alamofire.request(url).responseString { (response) -> Void in
            //check if the result has a value
            if let json_result = response.result.value {
                if let dataFromString = json_result.data(using: .utf8, allowLossyConversion: false) {
                    let json = JSON(data: dataFromString)
                
                self.categories = []
                for (_, parent): (String, JSON) in json {
                    self.categories.append([
                        "name": parent["name"].stringValue,
                        "slug": parent["slug"].stringValue
                        ])
                    self.categoriesString.append(parent["name"].stringValue)
                }
                
                self.cateogryDropDown.optionArray = self.categoriesString
     
                }
            } else {
                self.view.makeToast("No Category")
            }
            self.categoryActivity.isHidden = true
        }
        
    }
    
    func fetchTags() {
     
        
        self.tagActivity.isHidden = false
        
        let url = Site.init().TAGS + "?hide_empty=1&order_by=menu_order";
        
        Alamofire.request(url).responseString { (response) -> Void in
            //check if the result has a value
            if let json_result = response.result.value {
                if let dataFromString = json_result.data(using: .utf8, allowLossyConversion: false) {
                    let json = JSON(data: dataFromString)
                
                self.tags = []
                for (_, parent): (String, JSON) in json {
                    self.tags.append([
                        "name": parent["name"].stringValue,
                        "slug": parent["slug"].stringValue
                        ])
                    self.tagsString.append(parent["name"].stringValue)
                }
                
                self.tagDropDown.optionArray = self.tagsString
                }
            } else {
                self.view.makeToast("No Tag")
            }
            self.tagActivity.isHidden = true
        }
        
    }

    @IBAction func cancelTapped(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    @objc func priceSliderValueChanged(_ rangeSlider: RangeSlider) {
        self.priceRangeLbl.text = Site.init().CURRENCY + PriceFormatter.format(price: rangeSlider.lowerValue) + " -  " + Site.init().CURRENCY + PriceFormatter.format(price: rangeSlider.upperValue)
    }
    
    @IBAction func filterTapped(_ sender: Any) {
        self.dismiss(animated: false, completion: {
            if let delegate = self.delegate {
                var priceRange: Array<String> = [String(format: "%.2f", self.priceSlider.lowerValue), String(format: "%.2f", self.priceSlider.upperValue)]
                
                if (self.priceSlider.lowerValue == self.initialLower && self.priceSlider.upperValue == self.initialUpper) {
                    priceRange = []
                }
                
                if (self.cateogryDropDown.text?.isEmpty)! {
                    self.selected_category = ""
                }
                if (self.tagDropDown.text?.isEmpty)! {
                    self.selected_tag = ""
                }
                
                delegate.onFilterSubmit(category: self.selected_category, tag: self.selected_tag, priceRange: priceRange)
            }
        })
    }

}
