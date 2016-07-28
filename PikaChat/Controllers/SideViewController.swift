//
//  SideViewController.swift
//  PikaChat
//
//  Created by Praveen Gowda I V on 7/25/16.
//  Copyright © 2016 Gowda I V, Praveen. All rights reserved.
//

import UIKit
import FirebaseAuth

class SideViewController: UIViewController {
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    override func viewDidLoad() {
        usernameLabel.text = FIRAuth.auth()?.currentUser?.displayName
    }
    
    @IBAction func signoutUser() {
        Utils.logoutUser()
        dismissViewControllerAnimated(true, completion: nil)
    }
}
