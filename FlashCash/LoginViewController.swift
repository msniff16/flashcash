//
//  LoginViewController.swift
//  FlashCash
//
//  Created by Matthew Sniff on 10/22/15.
//  Copyright © 2015 FlashCash. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    var isEditingText = false
    @IBOutlet var contentView: UIView!

    // Get a reference to our posts
    let ref = Firebase(url:"https://flashcash.firebaseio.com")
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // clear text fields on focus
    func textFieldDidBeginEditing(textField: UITextField) {
        
        if(textField == emailField) {
            emailField.text = ""
        }
        else if(textField == passwordField) {
            passwordField.text = ""
        }
        
        if !isEditingText {
            UIView.animateWithDuration(0.3) { () -> Void in
                
                self.contentView.frame.origin.y -= 150
                self.isEditingText = true
                
            }
        }
        
    }
    
    @IBAction func tappedView(sender: UITapGestureRecognizer) {
        
        
        if isEditingText {
            UIView.animateWithDuration(0.3) { () -> Void in
                
                self.contentView.frame.origin.y += 150
                self.emailField.resignFirstResponder()
                self.passwordField.resignFirstResponder()
                self.isEditingText = false

            }
        }
        
    }
    


    // log user in
    @IBAction func onLogin(sender: AnyObject) {
        
        // must include email && password to login
        if(!emailField.text!.isEmpty && !passwordField.text!.isEmpty) {
            
            ref.authUser(emailField.text!, password: passwordField.text!) {
                error, authData in
                if error != nil {
                    print("no user with this email!")
                } else {
                    
                    let newRef = self.ref.childByAppendingPath("users").childByAppendingPath(authData.uid!)
                    newRef.observeEventType(.Value, withBlock: { snapshot in
                        let userType = snapshot.value.objectForKey("userType") as! String
                        if(userType == "providesCash") {
                            self.performSegueWithIdentifier("loginToWork", sender: nil)
                        }
                        else if(userType == "needsCash") {
                            self.performSegueWithIdentifier("loginToCashPage", sender: nil)
                        }
                    })
                }
            }
        }
        
        else {
            let alert = UIAlertController(title: "Empty Information", message: "Please fill out all fields before logging in.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Got It", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
        
    }
}
