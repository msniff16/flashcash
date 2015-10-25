//
//  PreferredPaymentViewController.swift
//  FlashCash
//
//  Created by Matthew Sniff on 10/17/15.
//  Copyright © 2015 FlashCash. All rights reserved.
//

import UIKit

class PreferredPaymentViewController: UIViewController, UITextFieldDelegate {
    
    // TODO: replace this with the carried over provider.
    //carried over variables
//    var registeredProvider: Provider!
    
    var registeredProvider: Provider = Provider()
    
    //outlets
    @IBOutlet weak var streetText: UITextField!
    @IBOutlet weak var cityText: UITextField!
    @IBOutlet weak var stateText: UITextField!
    @IBOutlet weak var zipText: UITextField!
    @IBOutlet weak var ssnText: UITextField!
    @IBOutlet weak var dobText: UITextField!
    @IBOutlet weak var contentView: UIView!
    
    var isEditingText = false


    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Delegates
        streetText.delegate = self
        cityText.delegate = self
        stateText.delegate = self
        zipText.delegate = self
        ssnText.delegate = self
        dobText.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // clear text fields on focus
    func textFieldDidBeginEditing(textField: UITextField) {
        
        if(textField == streetText) {
            streetText.text = ""
        }
        else if(textField == cityText) {
            cityText.text = ""
        }
        else if(textField == stateText) {
            stateText.text = ""
        }
        else if(textField == zipText) {
            zipText.text = ""
        }
        else if(textField == ssnText) {
            ssnText.text = ""
        }
        else if(textField == dobText) {
            dobText.text = ""
        }
        
        if !isEditingText {
            UIView.animateWithDuration(0.3) { () -> Void in
                
                self.contentView.frame.origin.y -= 130
                self.isEditingText = true
                
            }
        }
    }

    @IBAction func continueRegistration(sender: UIButton) {
        registeredProvider.street = streetText.text!
        registeredProvider.city = cityText.text!
        registeredProvider.state = stateText.text!
        registeredProvider.zip = zipText.text!
        registeredProvider.ssn = ssnText.text!
        registeredProvider.date_of_birth = dobText.text!
        
        performSegueWithIdentifier("registerAccount", sender: self)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destinationVC = segue.destinationViewController as! RegisterAccountVC
        destinationVC.registeredProvider = self.registeredProvider
    }
    
    
    @IBAction func tappedView(sender: UITapGestureRecognizer) {
        
        if isEditingText {
            UIView.animateWithDuration(0.3) { () -> Void in
                
                self.contentView.frame.origin.y += 130
                self.streetText.resignFirstResponder()
                self.zipText.resignFirstResponder()
                self.cityText.resignFirstResponder()
                self.stateText.resignFirstResponder()
                self.ssnText.resignFirstResponder()
                self.dobText.resignFirstResponder()
                self.isEditingText = false
            }
        }
        
    }
    
}
