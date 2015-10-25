//
//  RegisterViewController.swift
//  FlashCash
//
//  Created by Matthew Sniff on 10/17/15.
//  Copyright (c) 2015 FlashCash. All rights reserved.
//

import UIKit
import Firebase
import Alamofire
import SwiftyJSON

class RegisterViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var email: UITextField!
    @IBOutlet var phone: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var firstName: UITextField!
    @IBOutlet var lastName: UITextField!
    @IBOutlet var confirmPass: UITextField!
    @IBOutlet var contentView: UIView!
    var userType = ""
    var isEditingText = false
    var customerID: String!
    
    // Get a reference to our posts
    let ref = Firebase(url:"https://flashcash.firebaseio.com")
    
    // view loaded
    override func viewDidLoad() {
      
        super.viewDidLoad()
        print(userType)
        
    }

    // clear text fields on focus
    func textFieldDidBeginEditing(textField: UITextField) {
        
        if(textField == email) {
            email.text = ""
        }
        else if(textField == phone) {
            phone.text = ""
        }
        else if(textField == password) {
            password.text = ""
            password.secureTextEntry = true
        }
        else if(textField == confirmPass) {
            confirmPass.text = ""
            confirmPass.secureTextEntry = true
        }
        else if(textField == firstName) {
            firstName.text = ""
        }
        else if(textField == lastName) {
            lastName.text = ""
        }
        
        if !isEditingText {
            UIView.animateWithDuration(0.3) { () -> Void in
                
                self.contentView.frame.origin.y -= 130
                self.isEditingText = true
                
            }
        }
    }
    
    // register the user
    @IBAction func onRegister(sender: AnyObject) {
        
        // all fields must have text to save data
        if(email.text!.isEmpty || phone.text!.isEmpty || password.text!.isEmpty || confirmPass.text!.isEmpty || firstName.text!.isEmpty || lastName.text!.isEmpty)  {
            
            let alert = UIAlertController(title: "Empty Information", message: "Please fill out all fields before registering.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Got It", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            
        } else if(password.text != confirmPass.text) {
            
            let alert = UIAlertController(title: "Passwords do not match", message: "Please type in matching passwords.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Got It", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            
        } else if userType == "providesCash"{
                self.ref.createUser(self.email.text!, password: self.password.text!,
                    withValueCompletionBlock: { error, result in
                        
                        if error != nil {
                            // There was an error creating the account
                            print(error)
                        } else {
                            let uid = result["uid"] as? String
                            print("Successfully created user account with uid: \(uid)")
                            
                            // log user in automatically
                            self.ref.authUser(self.email.text!, password:self.password.text!) {
                                error, authData in
                                if error != nil {
                                    
                                    // Something went wrong. :(
                                    
                                } else {
                                    
                                    // Authentication just completed successfully :)
                                    // The logged in user's unique identifier
                                    print(authData.uid!  )
                                    
                                    // Create a new user dictionary accessing the user's info
                                    // provided by the authData parameter
                                    let newUser = [
                                        "provider": authData.provider,
                                        //"displayName": authData.providerData["displayName"] as! NSString as String,
                                        "email": self.email.text!,
                                        "phone": self.phone.text!,
                                        "firstName": self.firstName.text!,
                                        "lastName": self.lastName.text!,
                                        "password": self.password.text!,
                                        "userType": self.userType
                                    ]
                                    
                                    // Create a child path with a key set to the uid underneath the "users" node
                                    // This creates a URL path like the following:
                                    //  - https://<YOUR-FIREBASE-APP>.firebaseio.com/users/<uid>
                                    self.ref.childByAppendingPath("users")
                                        .childByAppendingPath(authData.uid!).setValue(newUser)
                                    self.performSegueWithIdentifier("registerToProvidePayment", sender: nil)
                                }
                            }
                        }
            })
        } else {
        
            //Send request to API endpoints to create customer on Braintree server. Will receive customerID from this that gets then submitted to Firebase.
            Alamofire.request(.POST, "http://flash-cash.herokuapp.com/api/v1/braintree/customers", parameters: [
                    "first_name": self.firstName.text!,
                    "last_name": self.lastName.text!,
                    "email": self.email.text!,
                    "phone": self.phone.text!
                ], encoding: ParameterEncoding.JSON, headers: nil).response { request, response, data, error in
                    if error != nil {
                        //handle error
                    } else {
                        //if no error, parse the response data. Response data contains dictionary with single entry for customer ID.
                        let customerData = JSON(data: data!)
                        if let id = customerData["customer_id"].string {
                            self.customerID = id
                            print(self.customerID)
                            
                            //create user
                            self.ref.createUser(self.email.text!, password: self.password.text!,
                                withValueCompletionBlock: { error, result in
                                    
                                    if error != nil {
                                        // There was an error creating the account
                                    } else {
                                        
                                        let uid = result["uid"] as? String
                                        print("Successfully created user account with uid: \(uid)")
                                        
                                        // log user in automatically
                                        self.ref.authUser(self.email.text!, password:self.password.text!) {
                                            error, authData in
                                            if error != nil {
                                                
                                                // Something went wrong. :(
                                                
                                            } else {
                                                
                                                //TODO: Make sure that we DO NOT ASSIGN CUSTOMER ID to providers
                                                
                                                // Authentication just completed successfully :)
                                                // The logged in user's unique identifier
                                                print(authData.uid!  )
                                                
                                                // Create a new user dictionary accessing the user's info
                                                // provided by the authData parameter
                                                let newUser = [
                                                    "provider": authData.provider,
                                                    //"displayName": authData.providerData["displayName"] as! NSString as String,
                                                    "email": self.email.text!,
                                                    "phone": self.phone.text!,
                                                    "firstName": self.firstName.text!,
                                                    "lastName": self.lastName.text!,
                                                    "password": self.password.text!,
                                                    "userType": self.userType,
                                                    "customer_id": self.customerID
                                                ]
                                                
                                                // Create a child path with a key set to the uid underneath the "users" node
                                                // This creates a URL path like the following:
                                                //  - https://<YOUR-FIREBASE-APP>.firebaseio.com/users/<uid>
                                                self.ref.childByAppendingPath("users")
                                                    .childByAppendingPath(authData.uid!).setValue(newUser)
                                                self.performSegueWithIdentifier("registerToCashScreen", sender: nil)
                                            }
                                        }
                                    }
                            })
                        }
                    }
            }
            
//            
//            usersRef.setValue(user, withCompletionBlock: {
//                (error:NSError?, ref:Firebase!) in
//                if (error != nil) {
//                   
//                    let alert = UIAlertController(title: "Error", message: "Data could not be saved. PLease try again.", preferredStyle: UIAlertControllerStyle.Alert)
//                    alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
//                    self.presentViewController(alert, animated: true, completion: nil)
//                    
//                } else {
//                    
//                    // log user in automatically
//                    ref.authUser(self.email.text!, password: self.password.text!) {
//                        error, authData in
//                        if error != nil {
//                            
//                            // an error occured while attempting login
//                            
//                        } else {
//                           
//                            // user is logged in, check authData for data
//                            // segue to next screen based on userType
//                            if(self.userType == "needsCash") {
//                                self.performSegueWithIdentifier("registerToCashScreen", sender: nil)
//                            } else if(self.userType == "providesCash") {
//                                self.performSegueWithIdentifier("registerToProvidePayment", sender: nil)
//                            }
//                            
//                        }
//                    }
//                    
//                    
//
//                }
//            })
            
        }
    
    }
    
    // segue to next screen
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        if (segue.identifier == "registerToCashScreen") {
            
            if let cashVC = segue.destinationViewController as? CashViewController {
                
            }
        }
        
        if (segue.identifier == "registerToProvidePayment") {
            
            if let registerProvider = segue.destinationViewController as? PreferredPaymentViewController {
                registerProvider.registeredProvider = Provider(first_name: firstName.text!, last_name: lastName.text!, email: email.text!, phone: phone.text!)
            }
        }
    }

    
    // tapped sceen --> dismiss keyboard
    @IBAction func tappedView(sender: UITapGestureRecognizer) {
        
        
        if isEditingText {
            UIView.animateWithDuration(0.3) { () -> Void in
                
                self.contentView.frame.origin.y += 130
                self.email.resignFirstResponder()
                self.phone.resignFirstResponder()
                self.firstName.resignFirstResponder()
                self.lastName.resignFirstResponder()
                self.password.resignFirstResponder()
                self.confirmPass.resignFirstResponder()
                self.isEditingText = false
            }
        }

    }
    



}
