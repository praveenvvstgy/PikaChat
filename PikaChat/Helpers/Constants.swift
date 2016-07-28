//
//  Constants.swift
//  PikaChat
//
//  Created by Gowda I V, Praveen on 7/19/16.
//  Copyright © 2016 Gowda I V, Praveen. All rights reserved.
//

import UIKit

struct Colors {
    static let splashTopGradient = UIColor(red:0.73, green:0.11, blue:0.07, alpha:1.00)
    static let splashBottomGradient = UIColor(red:0.85, green:0.13, blue:0.09, alpha:1.00)
    static let pageMenuSelectedColor = UIColor(red:0.13, green:0.13, blue:0.14, alpha:1.00)
    static let selectedpageMenuItemLabelColor = UIColor(red:0.13, green:0.13, blue:0.14, alpha:1.00)
    static let unselectedPageMenuItemLabelColor = UIColor(red:0.60, green:0.60, blue:0.60, alpha:1.00)
    static let selectedTextFieldColor = UIColor(red:0.97, green:0.97, blue:0.97, alpha:1.00)
    static let errorColor = UIColor(red:1.00, green:0.29, blue:0.29, alpha:1.00)
}

struct Fonts {
    static func openSansSemiBold(size: CGFloat) -> UIFont {
        return UIFont(name: "OpenSans-Semibold", size: size)!
    }
}