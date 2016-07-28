//
//  AuthBaseController.swift
//  PikaChat
//
//  Created by Gowda I V, Praveen on 7/19/16.
//  Copyright © 2016 Gowda I V, Praveen. All rights reserved.
//

import UIKit
import PageMenu

class AuthBaseController: UIViewController {
    var pageMenu: CAPSPageMenu!
    var selectedPageIndex: Int!
    
    override func viewDidLoad() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let loginViewController = storyboard.instantiateViewControllerWithIdentifier("loginViewController") as! LoginViewController
        loginViewController.title = "LOGIN"
        let signupViewController = storyboard.instantiateViewControllerWithIdentifier("signupViewController") as! SignupViewController
        signupViewController.title = "REGISTER"
        
        let controllerArray = [loginViewController, signupViewController]
        
        let parameters: [CAPSPageMenuOption] = [
            .ViewBackgroundColor(UIColor.whiteColor()),
            .UseMenuLikeSegmentedControl(true),
            .MenuHeight(47),
            .ScrollMenuBackgroundColor(UIColor.whiteColor()),
            .SelectionIndicatorColor(Colors.pageMenuSelectedColor),
            .SelectedMenuItemLabelColor(Colors.pageMenuSelectedColor),
            .MenuItemFont(Fonts.openSansSemiBold(12))
        ]
        
        pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: CGRectMake(0.0, 0, self.view.frame.width, self.view.frame.height), pageMenuOptions: parameters)
        
        self.view.addSubview(pageMenu.view)
        
        pageMenu.moveToPage(selectedPageIndex)
    }
    
    override func viewWillLayoutSubviews() {
        if UIApplication.sharedApplication().statusBarOrientation == .Portrait {
            var frame = pageMenu.view.frame
            frame.origin.y = UIApplication.sharedApplication().statusBarFrame.size.height
            pageMenu.view.frame = frame
        } else {
            var frame = pageMenu.view.frame
            frame.origin.y = 0
            pageMenu.view.frame = frame
        }
    }
}
