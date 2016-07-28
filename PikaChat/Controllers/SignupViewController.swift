//
//  SignupViewController.swift
//  PikaChat
//
//  Created by Gowda I V, Praveen on 7/19/16.
//  Copyright © 2016 Gowda I V, Praveen. All rights reserved.
//

import UIKit
import Validator
import FirebaseAuth
import Firebase
import MBProgressHUD
import FirebaseDatabase
import MMDrawerController

class SignupViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var errorLabelHeight: NSLayoutConstraint!
        
    override func viewDidLoad() {
        
        usernameField.addLeftIconToTableView(UIImage(named: "usericon"))
        emailField.addLeftIconToTableView(UIImage(named: "emailicon"))
        passwordField.addLeftIconToTableView(UIImage(named: "passwordicon"))
        
        usernameField.delegate = self
        passwordField.delegate = self
        emailField.delegate = self
        
        // Attach Form Validation
        
        // Username Field - required, 3-16 chars, no special characters
        var usernameRules = ValidationRuleSet<String>()
        usernameRules.addRule(ValidationRuleRequired(failureError: ValidationError(message: "Username is required")))
        usernameRules.addRule(ValidationRuleLength(min: 3, max: 16, failureError: ValidationError(message: "Username length should be between 3-16 chars")))
        usernameRules.addRule(ValidationRulePattern(pattern: "[a-z0-9_-]*", failureError: ValidationError(message: "Username can contain letters, numbers and _ and - only")))
        
        usernameField.validationRules = usernameRules
        usernameField.validateOnEditingEnd(true)
        usernameField.validationHandler = validationHandler
        
        // Email Field - required, valid email
        var emailRules = ValidationRuleSet<String>()
        emailRules.addRule(ValidationRuleRequired(failureError: ValidationError(message: "Email is required")))
        emailRules.addRule(ValidationRulePattern(pattern: .EmailAddress, failureError: ValidationError(message: "Invalid Email")))
        
        emailField.validationRules = emailRules
        emailField.validateOnEditingEnd(true)
        emailField.validationHandler = validationHandler
        
        // Password Field - required, min 8 chars
        var passwordRules = ValidationRuleSet<String>()
        passwordRules.addRule(ValidationRuleRequired(failureError: ValidationError(message: "Password is required")))
        passwordRules.addRule(ValidationRuleLength(min: 3, max: 100, failureError: ValidationError(message: "Password should have min. 8 chars")))
        
        passwordField.validationRules = passwordRules
        passwordField.validateOnEditingEnd(true)
        passwordField.validationHandler = validationHandler
        
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
            if emailField.validate() == .Valid {
                if passwordField.validate() == .Valid {
                    return true
                }
            }
        }
        return false
    }
    
    func clearAllFields() {
        usernameField.text = ""
        emailField.text = ""
        passwordField.text = ""
    }
    
    // MARK: Signup Handling
    @IBAction func initiateSignup() {
        if validateForm() == true {
            
            let loadingIndicator = MBProgressHUD.showHUDAddedTo(view, animated: true)
            loadingIndicator.label.text = "Registering"
            
            // Attemp User creation with email and password
            FIRAuth.auth()?.createUserWithEmail(emailField.text!, password: passwordField.text!) { (user, error) in
                if let error = error {
                    self.showErrorForTime(5, message: error.localizedDescription)
                    loadingIndicator.hideAnimated(true)
                } else {
                    if let user = user {
                        // Set the display name to username the user provided
                        let changeRequest = user.profileChangeRequest()
                        changeRequest.displayName = self.usernameField.text
                        changeRequest.commitChangesWithCompletion({ (error) in
                            if let error = error {
                                self.showErrorForTime(5, message: error.localizedDescription)
                                loadingIndicator.hideAnimated(true)
                            } else {
                                // Store the username under /users and /usernames, both provided
                                // to and fro reference to username and uid which are used for validation
                                // during registration as well as during login
                                
                                // The below operation will fail if the username already exists
                                // because of the rules set in firebase and this acts as a check for 
                                // preventing duplicate username
                                FIRDatabase.database().reference().updateChildValues([
                                    "users/\(user.uid)/username": self.usernameField.text!,
                                    "users/\(user.uid)/email": self.emailField.text!,
                                    "usernames/\(self.usernameField.text!)": user.uid
                                    ], withCompletionBlock: { (error, reference) in
                                        if error != nil {
                                            // if the username already exists, we have to delete the user we
                                            // created with email and password below
                                            user.deleteWithCompletion({ (error) in
                                                if error != nil {
                                                    print(error?.localizedDescription)
                                                }
                                            })
                                            self.showErrorForTime(5, message: "Username already exists")
                                            loadingIndicator.hideAnimated(true)
                                        } else {
                                            // Registration Successful
                                            self.clearAllFields()
                                            loadingIndicator.hideAnimated(true)
                                            Utils.ifLoggedInRedirectToHome(self)
                                        }
                                })
                            }
                        })
                    }
                }
            }
        } else {
           showErrorForTime(5)
        }
    }
    
    //MARK: Error Label Handling
    func showErrorForTime(time: NSTimeInterval, message: String?) {
        errorLabel.text = message
        UIView.animateWithDuration(0.5) { 
            self.errorLabelHeight.constant = 44
            self.view.layoutIfNeeded()
        }
        Utils.delay(time, closure: {
            self.hideError()
        })
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

extension SignupViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.backgroundColor = Colors.selectedTextFieldColor
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        textField.backgroundColor = UIColor.whiteColor()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == usernameField {
            textField.resignFirstResponder()
            emailField.becomeFirstResponder()
        } else if textField == emailField {
            emailField.resignFirstResponder()
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            passwordField.resignFirstResponder()
            initiateSignup()
        }
        return true
    }
}
