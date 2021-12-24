//
//  MainCartViewController.swift
//  Phuck Brand
//
//  Created by Seun Oyeniyi on 11/1/21.
//  Copyright © 2021 Phuck Brand. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class MainCartViewController: UIViewController {

    @IBOutlet var singlePageView: UIView!
    @IBOutlet var categoriesCollectionView: UICollectionView!
    @IBOutlet var trayAgainView: UIView!
    @IBOutlet var topCartBtn: UIBarButtonItem!
    
    var cartNotification: UILabel!
    
    let userSession = UserSession()
    
    var pageViewController: ShopPageViewController!
    
    let activityViewController = ActivityViewController(message: "Loading...");
    let reuseIdentifier = "category_cell"
    var categories: Array<Dictionary<String, Any>> = [];
    var currentViewControllerIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setTabBarBorder()
      
        setupCartNotification()
    
        configurePageViewController()
        
        //get categories ready
        fetchCategories();
        
    }
    override func viewDidAppear(_ animated: Bool) {
        self.userSession.reload()
        self.updateCartNotification()
    }
    
    func configurePageViewController() {
        guard let pageViewController = UIStoryboard(name: "ShopPager", bundle: nil).instantiateViewController(withIdentifier: String(describing: ShopPageViewController.self)) as? ShopPageViewController else { return }
        self.pageViewController = pageViewController
        
//        self.pageViewController.view.frame = CGRect(x: 0, y: 0, width: self.singlePageView.frame.size.width, height: self.singlePageView.frame.size.height+40)
        
        pageViewController.delegate = self
        pageViewController.dataSource = self
       
        
//        addChild(pageViewController)
        addChildViewController(pageViewController)
//        pageViewController.didMove(toParent: self)
        pageViewController.didMove(toParentViewController: self)
        
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        singlePageView.addSubview(pageViewController.view)
        
        let views: [String: Any] = ["pageView": pageViewController.view]
        
        singlePageView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[pageView]-0-|", options: [], metrics: nil, views: views))
        singlePageView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[pageView]-0-|", options: [], metrics: nil, views: views))
        
        guard let startingViewController = detailViewControllerAt(index: currentViewControllerIndex) else { return }
    
        pageViewController.setViewControllers([startingViewController], direction: .forward, animated: true, completion: nil)
    }
    
    func detailViewControllerAt(index: Int) -> ShopDataViewController? {
        if index >= categories.count || categories.count == 0 {
            return nil
        }
        guard let dataViewController = UIStoryboard(name: "ShopPager", bundle: nil).instantiateViewController(withIdentifier: String(describing: ShopDataViewController.self)) as? ShopDataViewController else { return nil }
        
        dataViewController.index = index
        dataViewController.category = categories[index]
        
        return dataViewController
    }
    func changePage(nextIndex: Int) {
        if nextIndex > currentViewControllerIndex {
            guard let newViewController = detailViewControllerAt(index: nextIndex) else { return }
            self.pageViewController.setViewControllers([newViewController], direction: .forward, animated: true, completion: nil)
        } else {
            guard let newViewController = detailViewControllerAt(index: nextIndex) else { return }
            self.pageViewController.setViewControllers([newViewController], direction: .reverse, animated: true, completion: nil)
        }
    }
    
    func fetchCategories() {
        if (!Connectivity.isConnectedToInternet) {
            self.view.makeToast("Bad internet connection!")
            self.trayAgainView.isHidden = false
            return
        }
        self.trayAgainView.isHidden = true
        present(activityViewController, animated: true, completion: nil)
        self.categoriesCollectionView.isHidden = true
        
        let url = Site.init().CATEGORIES + "?hide_empty=1";
        Alamofire.request(url).responseJSON { (response) -> Void in
            //check if the result has a value
            if let json_result = response.result.value {
                let json = JSON(json_result)
                //add default (all)
                self.categories.append([
                    "name": "ALL",
                    "slug": "all"
                    ])
                for (_, subJson): (String, JSON) in json {
                    if (subJson["slug"] == "uncategorized") { continue } //remove uncategorize
                    self.categories.append([
                        "name": subJson["name"].stringValue.uppercased(),
                        "slug": subJson["slug"].stringValue,
                        ])
                }
                self.categoriesCollectionView.isHidden = false
                DispatchQueue.main.async {
                    self.categoriesCollectionView.reloadData()
                    let indexPath = self.categoriesCollectionView.indexPathsForSelectedItems?.last ?? IndexPath(item: 0, section: 0)
                    self.categoriesCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionViewScrollPosition.centeredHorizontally)
                    self.collectionView(self.categoriesCollectionView, didSelectItemAt: indexPath)
                }
                self.trayAgainView.isHidden = true
            } else {
                //no result
                self.view.makeToast("Unable to connect shop.. Try Again!")
                self.trayAgainView.isHidden = false
            }
            //after every thing
            self.activityViewController.dismiss(animated: false, completion: nil)
        }
    }
    
    
    @IBAction func refreshBtnTapped(_ sender: UIButton) {
        fetchCategories()
    }
    

    @IBAction func menuTapped(_ sender: Any) {
        self.tabsDelegate.menuTapped()
    }
    
    @objc func cartMenuTapped(_ sender: UIButton) {
        self.tabsDelegate.cartMenuTapped()
    }
    
    func setupCartNotification() {
        let filterBtn = UIButton(type: .system)
        filterBtn.frame = CGRect.init(x: 0, y: 0, width: 30, height: 30)
        filterBtn.setImage(UIImage(named: "icons8_shopping_cart")?.withRenderingMode(.alwaysTemplate), for: .normal)
        filterBtn.tintColor = UIColor.black
        filterBtn.addTarget(self, action: #selector(cartMenuTapped(_:)), for: .touchUpInside)
        
        cartNotification = UILabel.init(frame: CGRect.init(x: 20, y: 2, width: 15, height: 15))
        cartNotification.backgroundColor = UIColor.red
        cartNotification.clipsToBounds = true
        cartNotification.layer.cornerRadius = 7
        cartNotification.textColor = UIColor.white
        cartNotification.font = cartNotification.font.withSize(10)
        cartNotification.textAlignment = .center
        cartNotification.text = "0"
        filterBtn.addSubview(cartNotification)
        topCartBtn.customView = filterBtn
        
        cartNotification.isHidden = true //hidden by default
        
        //update cartNofication from server
        updateCartNotification()
    }
    
    
    func updateCartNotification() {
        let url = Site.init().CART + userSession.ID
        
        Alamofire.request(url).responseJSON { (response) -> Void in
            //check if the result has a value
            if let json_result = response.result.value {
                let json = JSON(json_result)
                if (json["contents_count"].intValue > 0) {
                    self.cartNotification.text = json["contents_count"].stringValue
                    self.cartNotification.isHidden = false
                } else {
                    self.cartNotification.isHidden = true
                }
            }
        }
    }
    

    

}

//FOR COLLECTION CONTROLLER DELEGATES
extension MainCartViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.categories.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //get a reference to our story board
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PageCategoryCollectionViewCell
        //use the outlet in our custom calss to get a reference to the UILabel in the cell
        if let name = self.categories[indexPath.row]["name"] as? String {
            cell.nameLabel.text = name
        }
        cell.backgroundColor = UIColor.white
        //for first time
        if indexPath.row == 0 {
            cell.backgroundColor = UIColor(rgb: 0xF1F1F1)
        }
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //handle tap events
        changePage(nextIndex: indexPath.item)
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = UIColor(rgb: 0xF1F1F1)
        
//        print("You selected cell #\(indexPath.item)!")
    }
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = UIColor(rgb: 0xF1F1F1)
    }
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = UIColor(rgb: 0xFFFFFF)
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = UIColor(rgb: 0xFFFFFF)
    }
}

//FOR PAGE VIEW CONTROLLER DELEGATES
extension MainCartViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    //to hide bottom indicator
//    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
//        return currentViewControllerIndex
//    }
//
//    func presentationCount(for pageViewController: UIPageViewController) -> Int {
//        return categories.count
//    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let dataViewController = viewController as? ShopDataViewController
        
        guard var currentIndex = dataViewController?.index else { return nil }
        
        currentViewControllerIndex = currentIndex
        
        if currentIndex == 0 {
            return nil
        }
        currentIndex -= 1
        
        return detailViewControllerAt(index: currentIndex)
    }
    

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let dataViewController = viewController as? ShopDataViewController
        
        guard var currentIndex = dataViewController?.index else { return nil }
        
        if currentIndex == categories.count {
            return nil
        }
        
        currentIndex += 1
        
        currentViewControllerIndex = currentIndex
        
        return detailViewControllerAt(index: currentIndex)
    }

    
}



