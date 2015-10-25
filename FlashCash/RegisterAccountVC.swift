//
//  RegisterAccountVC.swift
//  FlashCash
//
//  Created by Julius Danek on 10/21/15.
//  Copyright © 2015 FlashCash. All rights reserved.
//

import UIKit
import SwiftyJSON
import Firebase

class RegisterAccountVC: UIViewController, UITextFieldDelegate {
    
    var registeredProvider: Provider!
    
    let client = APIClient.sharedInstance()
    
    @IBOutlet weak var accountText: UITextField!
    @IBOutlet weak var routingText: UITextField!
    
    @IBOutlet var contentView: UIView!
    
    var userId: String?
    var userEmail: String?
    var isEditingText = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //delegates
        accountText.delegate = self
        routingText.delegate = self
        
        // user credz
        Auth.authorize() { (userEmail, userID, customerID, error) -> Void in
            if error != nil {
                //handle error
            } else {
                self.userEmail = userEmail
                self.userId = userID
            }
        }
        

    }
    
    
    // clear text fields on focus
    func textFieldDidBeginEditing(textField: UITextField) {
        
        if(textField == accountText) {
            accountText.text = ""
        }
        else if(textField == routingText) {
            routingText.text = ""
        }

        if !isEditingText {
            UIView.animateWithDuration(0.3) { () -> Void in
                
                self.contentView.frame.origin.y -= 50
                self.isEditingText = true
                
            }
        }
    }
    
    
    @IBAction func tappedView(sender: UITapGestureRecognizer) {
        
        if isEditingText {
            UIView.animateWithDuration(0.3) { () -> Void in
                
                self.contentView.frame.origin.y += 130
                self.routingText.resignFirstResponder()
                self.accountText.resignFirstResponder()
                self.isEditingText = false
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func finishRegistration(sender: UIButton) {
        registeredProvider.account_number = accountText.text!
        registeredProvider.routing_number = routingText.text!
        
        //TODO: remove testProvider and enter actual provider
        let testProvider = Provider()
//        registeredProvider.tos_accepted = true
        client.callAPI(.MerchantAccount, parameters: testProvider.createParamDict()) { (result, error) -> Void in
            print(error)
            print(result)
            if error != nil {
                //TODO: handle error
                print(error)
            } else {
                if let id = result!["merchant_account"]["id"].string {
                    let merchant_id = id
                    let active = false
                    let cashAmount = "0"
                    print(merchant_id)
                    
                    // save id and status for your account
                    let runnerRef = Firebase(url:"https://flashcash.firebaseio.com/users").childByAppendingPath(self.userId!)
                    let merchantId = ["merchant_id": merchant_id]
                    let status = ["active": false]
                    runnerRef.updateChildValues(merchantId)
                    runnerRef.updateChildValues(status)
                    self.performSegueWithIdentifier("registerToStartWork", sender: nil)
                }
            }
        }
        
    }
    
}
