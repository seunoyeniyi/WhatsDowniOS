//
//  CustomViews.swift
//  WhatsDown
//
//  Created by Seun Oyeniyi on 12/24/21.
//  Copyright © 2021 Phuck Brand. All rights reserved.
//

import UIKit


class ShimmerView: UIView {
    
        override public class var layerClass: AnyClass { return CAGradientLayer.self }
    
        var gradientLayer: CAGradientLayer { return layer as! CAGradientLayer }
    
    var gradientColorOne : CGColor = UIColor(white: 0.95, alpha: 0.6).cgColor
    var gradientColorTwo : CGColor = UIColor(white: 1, alpha: 0.6).cgColor
    
    
    
    func addGradientLayer() -> CAGradientLayer {
        
      
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.colors = [gradientColorOne, gradientColorTwo, gradientColorOne]
        gradientLayer.locations = [0.0, 0.5, 1.0]
       
        
        return gradientLayer
    }
    
    func addAnimation() -> CABasicAnimation {
        
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1.0, -0.5, 0.0]
        animation.toValue = [1.0, 1.5, 2.0]
        animation.repeatCount = .infinity
        animation.duration = 0.9
        return animation
    }
    
    func startAnimating() {
        
        let gradientLayer = addGradientLayer()
        let animation = addAnimation()
        
        gradientLayer.add(animation, forKey: animation.keyPath)
    }
    
    func stopAnimating() {
        let gradientLayer = addGradientLayer()
        gradientLayer.removeAllAnimations()
    }
    
}

class ShimmerViewContainer: UIView {
    func startProcesses(of view: UIView) {
        for subView in view.subviews {
            if (subView.isKind(of: ShimmerView.self)) {
                let shimView = subView as! ShimmerView
                shimView.startAnimating()
            }
            startProcesses(of: subView)
        }
    }
    func startShimmering() {
        startProcesses(of: self)
    }
    
    func stopProcesses(of view: UIView) {
        for subView in view.subviews {
            if (subView.isKind(of: ShimmerView.self)) {
                let shimView = subView as! ShimmerView
                shimView.stopAnimating()
            }
            stopProcesses(of: subView)
        }
    }
    func stopShimmering() {
        stopProcesses(of: self)
    }
}

class DynamicHeightCollectionView: UICollectionView {
    override func layoutSubviews() {
        super.layoutSubviews()
        if !__CGSizeEqualToSize(bounds.size, self.intrinsicContentSize) {
            self.invalidateIntrinsicContentSize()
        }
    }
    override var intrinsicContentSize: CGSize {
        return contentSize
    }
}

class WishListButton: UIButton {
    
            override init(frame: CGRect) {
                super.init(frame: frame)
                setupView()
            }
    
            required init?(coder aDecoder: NSCoder) {
                super.init(coder: aDecoder)
                setupView()
            }
            override func layoutSubviews() {
                super.layoutSubviews()
                setupView()
            }
            override func awakeFromNib() {
                setupView()
            }
            override func prepareForInterfaceBuilder() {
                super.prepareForInterfaceBuilder()
                setupView()
            }
    
        
    func setupView() {
        layer.shadowColor = UIColor(red: 0, green: 178/255, blue: 186/255, alpha: 1.0).cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 1.0
        layer.masksToBounds = false
        layer.cornerRadius = 0.5 * bounds.size.width
        
      
    }
}

class ListView: UIView {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        backgroundColor = UIColor(rgb: 0xF1F1F1)
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        backgroundColor = UIColor.white
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        backgroundColor = UIColor.white
    }
    
}

class BorderView: UIView {
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            setupView()
        }
    }
    @IBInspectable var borderColor: UIColor = UIColor.black {
        didSet {
            setupView()
        }
    }
    @IBInspectable var borderWidth: CGFloat = 1.0 {
        didSet {
            setupView()
        }
    }
    override func awakeFromNib() {
        setupView()
    }
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupView()
    }
    
    func setupView() {
        self.layer.cornerRadius = cornerRadius
        self.clipsToBounds = true
        self.layer.borderColor = borderColor.cgColor
        self.layer.borderWidth = borderWidth
    }
}


class CircleLabel: UILabel {
    
    @IBInspectable var cornerRadius: CGFloat = 7 {
        didSet {
            setupView()
        }
    }
  
    override func awakeFromNib() {
        setupView()
    }
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupView()
    }
    
    func setupView() {
        self.clipsToBounds = true
        self.layer.cornerRadius = cornerRadius
        self.textAlignment = .center
    }
    
    
}


