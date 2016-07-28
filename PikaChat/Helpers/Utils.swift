//
//  Utils.swift
//  PikaChat
//
//  Created by Praveen Gowda I V on 7/24/16.
//  Copyright © 2016 Gowda I V, Praveen. All rights reserved.
//

import Foundation
import FirebaseAuth
import MMDrawerController
import FirebaseDatabase
import GeoFire
import CoreLocation
import PermissionScope


class Utils {
    
    static var databaseRef = FIRDatabase.database().reference()
    static var geoFireRef = GeoFire(firebaseRef: databaseRef.child("/geodata"))
    static var currentLocation: CLLocation!
    
    static func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    static func logoutUser() {
        try! FIRAuth.auth()?.signOut()
    }
    
    static func getDrawerController(viewController: UIViewController) -> MMDrawerController? {
        if viewController.parentViewController?.isKindOfClass(MMDrawerController) == true {
            return viewController.parentViewController as? MMDrawerController
        }
        return nil
    }
    
    static func getUsernameString(name: String) -> NSAttributedString {
        let iconAttributes = [
            NSFontAttributeName: UIFont(name: "OpenSans-Semibold", size: 10)!,
            NSForegroundColorAttributeName: UIColor(red:0.93, green:0.08, blue:0.08, alpha:1.00)
        ]
        
        let textAttributes = [
            NSFontAttributeName: UIFont(name: "OpenSans-Semibold", size: 10)!,
        ]
        let usernameIcon = NSMutableAttributedString(string: " ● ", attributes: iconAttributes)
        let usernameText = NSAttributedString(string: name, attributes: textAttributes)
        usernameIcon.appendAttributedString(usernameText)
        return usernameIcon
    }
    
    static func ifLoggedInRedirectToHome(fromVC: UIViewController) {
        if FIRAuth.auth()?.currentUser != nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let homeNavigationViewController = storyboard.instantiateViewControllerWithIdentifier("homeNavigationViewController") as! BaseNavigationController
            let sideViewController = storyboard.instantiateViewControllerWithIdentifier("sideViewController") as! SideViewController
            let drawerController = MMDrawerController(centerViewController: homeNavigationViewController, leftDrawerViewController: sideViewController)
            drawerController.openDrawerGestureModeMask = .All
            drawerController.closeDrawerGestureModeMask = .All
            fromVC.presentViewController(drawerController, animated: true, completion: nil)
        }
    }
    
    static func addNewPost(postText: String, username: String, completion: () -> Void, failure: () -> Void) {
        let postKey = FIRDatabase.database().reference().child("/posts").childByAutoId().key
        let post = [
            "text": postText,
            "username": username,
            "timestamp": String(NSDate())
        ]
        let postUpdates = [
            "/posts/\(postKey)": post,
            "/user-posts/\(username)/\(postKey)": postText
        ]
        databaseRef.updateChildValues(postUpdates as [NSObject : AnyObject]) { (error, ref) in
            if error != nil {
                failure()
            } else {
                geoFireRef.setLocation(LocationHelper.sharedHelper.currentLocation, forKey: postKey, withCompletionBlock: { (error) in
                    if error != nil {
                        failure()
                    } else {
                        completion()
                    }
                })
            }
        }
    }
}