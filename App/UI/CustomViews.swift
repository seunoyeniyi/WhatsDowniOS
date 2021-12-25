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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        startAnimating()
    }
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            startAnimating()
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
//
//class ShimmerView: UIView, CAAnimationDelegate {
//
//    override public class var layerClass: AnyClass { return CAGradientLayer.self }
//
//    var gradientLayer: CAGradientLayer { return layer as! CAGradientLayer }
//
//
//    var gradientSet = [[CGColor]]()
//    var currentGradient: Int = 0
//
//    let gradientOne = UIColor(red: 48/255, green: 62/255, blue: 103/255, alpha: 1).cgColor
//    let gradientTwo = UIColor(red: 244/255, green: 88/255, blue: 53/255, alpha: 1).cgColor
//    let gradientThree = UIColor(red: 196/255, green: 70/255, blue: 107/255, alpha: 1).cgColor
//
//
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupView()
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        setupView()
//    }
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        setupView()
//    }
//    override func awakeFromNib() {
//        setupView()
//    }
//    override func prepareForInterfaceBuilder() {
//        super.prepareForInterfaceBuilder()
//        setupView()
//    }
//
//    func setupView() {
//
//        gradientSet.append([gradientOne, gradientTwo])
//        gradientSet.append([gradientTwo, gradientThree])
//        gradientSet.append([gradientThree, gradientOne])
//
//        gradientLayer.colors = gradientSet[currentGradient]
//        gradientLayer.startPoint = CGPoint(x:0, y:0)
//        gradientLayer.endPoint = CGPoint(x:1, y:1)
//        gradientLayer.drawsAsynchronously = true
//
//        //animate
//        animateGradient()
//
//    }
//
//    func animateGradient() {
//        if currentGradient < gradientSet.count - 1 {
//            currentGradient += 1
//        } else {
//            currentGradient = 0
//        }
//
//        let gradientChangeAnimation = CABasicAnimation(keyPath: "colors")
//        gradientChangeAnimation.duration = 5.0
//        gradientChangeAnimation.toValue = gradientSet[currentGradient]
//        gradientChangeAnimation.fillMode = kCAFillModeForwards
//        gradientChangeAnimation.isRemovedOnCompletion = false
//        gradientLayer.add(gradientChangeAnimation, forKey: "colorChange")
//    }
//
//    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
//        if flag {
//            gradientLayer.colors = gradientSet[currentGradient]
//            animateGradient()
//        }
//    }
//
//}

