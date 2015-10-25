//
//  ProfileVC.swift
//  FlashCash
//
//  Created by Julius Danek on 10/20/15.
//  Copyright © 2015 FlashCash. All rights reserved.
//

import UIKit
import Firebase


//Administers settings for the app

class ProfileVC: UIViewController {
    
    var userId: String?
    var userEmail: String?
    var customer: String?
    var paymentMethods: [String: AnyObject]!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.paymentMethods = [String:AnyObject]()

        Auth.authorize() { (userEmail, userID, customerID, error) -> Void in
            if error != nil {
                //handle error
            } else {
                self.userId = userID
                
                // check if you have any open requests being sent
                let ref = Firebase(url:"https://flashcash.firebaseio.com/users").childByAppendingPath(self.userId!).childByAppendingPath("Payment_Methods")
                ref.observeEventType(.Value, withBlock: { snapshot in
                    if let methods = snapshot.value as? [String: AnyObject] {
                        for (key, value) in methods {
                            self.paymentMethods[key] = value
                        }
                    }
                })
                
            }
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        // go to post screen
//        if segue.identifier == "embedded" {
//            let commentsTable: ContainerViewController = segue.destinationViewController as! ContainerViewController
//            commentsTable.paymentMethods = self.paymentMethods
//        } else
        if segue.identifier == "AddPayments" {
            let payments = segue.destinationViewController as! AddPaymentVC
            payments.paymentNumber = paymentMethods.keys.count
        }
        
    }
    
    @IBAction func cancelButton(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }


}
