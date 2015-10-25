//
//  ContainerViewController.swift
//  FlashCash
//
//  Created by Julius Danek on 10/24/15.
//  Copyright © 2015 FlashCash. All rights reserved.
//

import UIKit
import Braintree
import Firebase

class ContainerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var paymentMethods: [String: AnyObject]!
    var userId: String?
    
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
                    print(snapshot.value)
                    if let methods = snapshot.value as? [String: AnyObject] {
                        print(methods)
                        for (key, value) in methods {
                            self.paymentMethods[key] = value
                        }
                    }
                    print(self.paymentMethods)
                    self.tableView.reloadData()
                })
                
            }
        }
        tableView.delegate = self
        tableView.dataSource = self
        

        // Do any additional setup after loading the view.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return paymentMethods!.keys.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! CustomCell
        let dict = paymentMethods["number " + String(indexPath.row)] as! NSDictionary
        let label = dict["lastFour"] as! String
        let cardType = dict["cardType"] as! String
        cell.titleLabel!.text = label
        let card = BTUICardType(forBrand: cardType)
        cell.cardHint.setCardType(cardRecognizer(card), animated: false)
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func cardRecognizer (cardType: BTUICardType) -> BTUIPaymentMethodType {
        switch cardType.brand {
        case "AMEX":
            return .AMEX
        case "DinersClub":
            return .DinersClub
        case "Discover":
            return .Discover
        case "MasterCard":
            return .MasterCard
        case "Visa":
            return .Visa
        case "JCB":
            return .JCB
        case "Laser":
            return .Laser
        case "Maestro":
            return .Maestro
        case "UnionPay":
            return .UnionPay
        case "Solo":
            return .Solo
        case "Switch":
            return .Switch
        case "UKMaestro":
            return .UKMaestro
        case "PayPal":
            return .PayPal
        case "Coinbase":
            return .Coinbase
        default:
            return .Unknown
        }
    }

    
}
