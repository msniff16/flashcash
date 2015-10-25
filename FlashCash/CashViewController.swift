//
//  CashViewController.swift
//  FlashCash
//
//  Created by Matthew Sniff on 10/17/15.
//  Copyright © 2015 FlashCash. All rights reserved.
//

import UIKit
import Firebase

class CashViewController: UIViewController {

    let ref = Firebase(url: "https://flashcash.firebaseio.com")
    var userId: String?
    var userEmail: String?
    var customerID: String!
    
    @IBOutlet weak var cashLabel: UILabel!
    
    // view laoded
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // user's information
        ref.observeAuthEventWithBlock({ authData in
            if authData != nil {
                
                // user authenticated --> grab their data
                print("auth data: \(authData)")
                self.userId = authData.uid as NSString as String
                print("auth email: \(authData.uid)")
                
                let newRef = self.ref.childByAppendingPath("users")
                    .childByAppendingPath(authData.uid!)
                newRef.observeEventType(.Value, withBlock: { snapshot in
                    self.userEmail = snapshot.value.objectForKey("email")! as? String
                    self.customerID = snapshot.value.objectForKey("customer_id") as? String
                })
                
            }
        })
    }
    
    
    
    
    //MARK: Number Buttons
    //TODO: Check that you cannot put in 0 as first number
    
    @IBAction func One(sender: UIButton) {
        addNumber(1)
    }
    
    @IBAction func Two(sender: UIButton) {
        addNumber(2)
    }
    
    @IBAction func Three(sender: UIButton) {
        addNumber(3)
    }
    
    @IBAction func Four(sender: UIButton) {
        addNumber(4)
    }
    
    @IBAction func Five(sender: UIButton) {
        addNumber(5)
    }
    
    @IBAction func Six(sender: UIButton) {
        addNumber(6)
    }
    
    @IBAction func Seven(sender: UIButton) {
        addNumber(7)
    }
    
    @IBAction func Eight(sender: UIButton) {
        addNumber(8)
    }
    
    @IBAction func Nine(sender: UIButton) {
        addNumber(9)
    }
    
    @IBAction func Zero(sender: UIButton) {
        addNumber(0)
    }
    
    //TODO: Insert comma1s to make text better. Maybe even use NSMutableAttribute to change label instead.
    @IBAction func Backslash(sender: UIButton) {
        if cashLabel.text?.characters.count > 1 {
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.cashLabel.text = self.cashLabel.text?.substringToIndex((self.cashLabel.text?.endIndex.advancedBy(-1))!)
                }, completion: nil)
        }
    }
    
    func addNumber (number: Int) {
        let labelText = cashLabel.text!
        if labelText.characters.count < 6 {
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.cashLabel.text = labelText + "\(number)"
                }, completion: nil)
        }
    }
    
    
    //MARK: Request Money
    
    @IBAction func RequestMoney(sender: UIButton) {
        let index = cashLabel.text!.startIndex.advancedBy(1)
        let requestedAmount = cashLabel.text?.substringFromIndex(index)
        print(requestedAmount)
        self.performSegueWithIdentifier("cashToSearch", sender: requestedAmount)
    }
    
    
    @IBAction func profileButton(sender: UIButton) {
        performSegueWithIdentifier("ProfileVCSeg", sender: self)
    }
 
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ProfileVCSeg" {
            let profile = segue.destinationViewController as! ProfileVC
        }
        if segue.identifier == "cashToSearch" {
            let search = segue.destinationViewController as! StartSearchViewController
            search.requestedPayment = sender as? String
        }
    }
    
    
}
