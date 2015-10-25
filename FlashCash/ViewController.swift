
//
//  ViewController.swift
//  FlashCash
//
//  Created by Matthew Sniff on 10/17/15.
//  Copyright (c) 2015 FlashCash. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var needCashButton: UIButton!
    @IBOutlet var haveCashButton: UIButton!
  
    // view loaded
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // register as client
    @IBAction func onNeedCash(sender: UIButton) {
        performSegueWithIdentifier("launchToRegister", sender: "needsCash")
    }

    // register as provider of cash
    @IBAction func onHaveCash(sender: UIButton) {
        performSegueWithIdentifier("launchToRegister", sender: "providesCash")
    }
    
    @IBAction func onLogin(sender: AnyObject) {
        performSegueWithIdentifier("launchToLogin", sender: "providesCash")
    }
    
    // segue to next screen
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
      
        if (segue.identifier == "launchToRegister") {

            if let registerScreen = segue.destinationViewController as? RegisterViewController {
                registerScreen.userType = sender as! String
            }
        }
        
    }
    
}

