//
//  SplashViewController.swift
//  PikaChat
//
//  Created by Gowda I V, Praveen on 7/19/16.
//  Copyright © 2016 Gowda I V, Praveen. All rights reserved.
//

import UIKit
import ChameleonFramework
import PermissionScope

class SplashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = GradientColor(.TopToBottom, frame: self.view.bounds, colors: [Colors.splashTopGradient, Colors.splashBottomGradient])
    }
    
    override func viewDidAppear(animated: Bool) {
        LocationHelper.sharedHelper.showLocationPrompt()
        
        Utils.ifLoggedInRedirectToHome(self)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "moveToLogin" {
            if let destinationVC = segue.destinationViewController as? AuthBaseController {
                destinationVC.selectedPageIndex = 0
            }
        } else if segue.identifier == "moveToRegister" {
            if let destinationVC = segue.destinationViewController as? AuthBaseController {
                destinationVC.selectedPageIndex = 1
            }
        }
    }

}

