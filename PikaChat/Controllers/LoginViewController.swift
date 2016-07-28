//
//  LoginViewController.swift
//  PikaChat
//
//  Created by Gowda I V, Praveen on 7/19/16.
//  Copyright © 2016 Gowda I V, Praveen. All rights reserved.
//

import UIKit
import Validator
import FirebaseAuth
import MBProgressHUD
import FirebaseDatabase
import MMDrawerController
import IQKeyboardManagerSwift

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var errorLabelHeight: NSLayoutConstraint!
    
    var activeField: UITextField?
    
    override func viewDidLoad() {
        usernameField.addLeftIconToTableView(UIImage(named: "usericon"))
        passwordField.addLeftIconToTableView(UIImage(named: "passwordicon"))
        
        usernameField.delegate = self
        passwordField.delegate = self
        
        // Attach Form Validation
        
        // Username Field - required, 3-16 chars, no special characters
        var usernameRules = ValidationRuleSet<String>()
        usernameRules.addRule(ValidationRuleRequired(failureError: ValidationError(message: "Username is required")))
        usernameRules.addRule(ValidationRuleLength(min: 3, max: 16, failureError: ValidationError(message: "Username length should be between 3-16 chars")))
        usernameRules.addRule(ValidationRulePattern(pattern: "[a-z0-9_-]*", failureError: ValidationError(message: "Username can contain letters, numbers and _ and - only")))
        
        usernameField.validationRules = usernameRules
        usernameField.validateOnEditingEnd(true)
        usernameField.validationHandler = validationHandler
        
        // Password Field - required, min 8 chars
        var passwordRules = ValidationRuleSet<String>()
        passwordRules.addRule(ValidationRuleRequired(failureError: ValidationError(message: "Password is required")))
        passwordRules.addRule(ValidationRuleLength(min: 3, max: 100, failureError: ValidationError(message: "Password should have min. 8 chars")))
        
        passwordField.validationRules = passwordRules
        passwordField.validateOnEditingEnd(true)
        passwordField.validationHandler = validationHandler
        
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 43))
        button.backgroundColor = UIColor(red:0.83, green:0.07, blue:0.07, alpha:1.00)
        button.titleLabel?.font = UIFont(name: "OpenSans-Bold", size: 16)
        button.setTitle("GO", forState: .Normal)
        button.titleLabel?.textAlignment = .Center
        button.titleLabel?.textColor = UIColor.whiteColor()
        button.addTarget(self, action: #selector(initiateLogin), forControlEvents: .TouchUpInside)
        
        usernameField.inputAccessoryView = button
        passwordField.inputAccessoryView = button
    }
    
    // MARK: Form Handling
    func validationHandler(result: ValidationResult, control: UITextField) {
        switch result {
        case .Valid:
            errorLabel.text = nil
            hideError()
        case .Invalid(let failures):
            errorLabel.text = failures.first?.message
        }
    }
    func validateForm() -> Bool {
        if usernameField.validate() == .Valid {
            if passwordField.validate() == .Valid {
                return true
            }
        }
        return false
    }
    
    func clearAllFields() {
        usernameField.text = ""
        passwordField.text = ""
    }
    
    // MARK: Login Handling
    @IBAction func initiateLogin() {
        IQKeyboardManager.sharedManager().resignFirstResponder()
        if validateForm() == true {
            let loadingIndicator = MBProgressHUD.showHUDAddedTo(view, animated: true)
            loadingIndicator.label.text = "Logging In"
            // Check if username exists
            FIRDatabase.database().reference().child("usernames/\(usernameField.text!)").observeSingleEventOfType(.Value , withBlock: { (snapshot) in
                if snapshot.exists() {
                    if let uid = snapshot.value as? String {
                        // Fetch the email for the corresponding username
                        FIRDatabase.database().reference().child("users/\(uid)").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                            if snapshot.exists() {
                                if let userDict = snapshot.value as? [String: AnyObject] {
                                    if let email = userDict["email"] as? String {
                                        // Signing using the email retreived and the password entered
                                        FIRAuth.auth()?.signInWithEmail(email, password: self.passwordField.text!, completion: { (user, error) in
                                            loadingIndicator.hideAnimated(true)
                                            if error != nil {
                                                self.showErrorForTime(5, message: error?.localizedDescription)
                                            } else {
                                                // Sign In Successful
                                                self.clearAllFields()
                                                Utils.ifLoggedInRedirectToHome(self)

                                            }
                                        })
                                    }
                                }
                            } else {
                                loadingIndicator.hideAnimated(true)
                                // Ideally this never gets executed because of the rules set in Firebase
                                self.showErrorForTime(5, message: "Username doesn't exist")

                            }
                        })
                    } else {
                        print("Cannot convert UID to string")
                    }
                } else {
                    loadingIndicator.hideAnimated(true)
                    self.showErrorForTime(5, message: "Username doesn't exist")
                }
            })

        } else {
            showErrorForTime(5)
        }
    }
    
    //MARK: Error Label Handling
    func showErrorForTime(time: NSTimeInterval, message: String?) {
        errorLabel.text = message
        showErrorForTime(time)
    }
    
    func showErrorForTime(time: NSTimeInterval) {
        UIView.animateWithDuration(0.5) {
            self.errorLabelHeight.constant = 44
            self.view.layoutIfNeeded()
        }
        Utils.delay(time, closure: {
            self.hideError()
        })
    }
    
    func hideError() {
        UIView.animateWithDuration(0.5) {
            self.errorLabelHeight.constant = 0
            self.view.layoutIfNeeded()
        }
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.backgroundColor = Colors.selectedTextFieldColor
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        textField.backgroundColor = UIColor.whiteColor()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == usernameField {
            textField.resignFirstResponder()
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            passwordField.resignFirstResponder()
            initiateLogin()
        }
        return true
    }
}
