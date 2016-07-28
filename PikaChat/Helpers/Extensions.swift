//
//  Extensions.swift
//  PikaChat
//
//  Created by Praveen Gowda I V on 7/23/16.
//  Copyright © 2016 Gowda I V, Praveen. All rights reserved.
//

import UIKit
import MMDrawerController

extension CALayer {
    func setBorderColorFromUIColor(color: UIColor) {
        self.borderColor = color.CGColor
    }
}

extension UITextField {
    func addLeftIconToTableView(image: UIImage?) {
        let leftImageView = UIImageView()
        leftImageView.image = image
        leftImageView.contentMode = .ScaleAspectFit
        
        let leftView = UIView()
        leftView.addSubview(leftImageView)
        
        leftView.frame = CGRectMake(0, 0, 60, 60)
        leftImageView.frame = CGRectMake(20, 20, 20, 20)
        
        self.leftView = leftView
        leftViewMode = .Always
    }
}

extension MMDrawerController {
    public override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}

extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
}