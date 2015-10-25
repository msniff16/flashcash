//
//  AddPaymentVC.swift
//  FlashCash
//
//  Created by Julius Danek on 10/21/15.
//  Copyright © 2015 FlashCash. All rights reserved.
//

import UIKit
import Braintree
import Alamofire
import SwiftyJSON
import Firebase

class AddPaymentVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var cardHint: BTUICardHint!
    @IBOutlet weak var cardNumberField: UITextField!
    @IBOutlet weak var expirationDate: UITextField!
    @IBOutlet weak var cvvField: UITextField!
    
    let client = APIClient.sharedInstance()
    var clientToken: String!
    var userId: String?
    var userEmail: String?
    var paymentNumber: Int?
    var customerID: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // user credz
        Auth.authorize() { (userEmail, userID, customerID, error) -> Void in
            if error != nil {
                //handle error
            } else {
                self.userEmail = userEmail
                self.userId = userID
                self.customerID = customerID
                self.client.callAPI(.ClientToken, parameters: self.client.clientTokenParams(self.customerID!)) { (result, error) -> Void in
                    if error != nil {
                        //handle error
                    } else {
                        if let token = result!["client_token"].string {
                            self.clientToken = token
                        }
                    }
                }
            }
        }
        
        //set initial card Type
        cardHint.cardType = BTUIPaymentMethodType.Unknown
        cardHint.displayMode = BTCardHintDisplayMode.CardType
        
        //Delegates
        cardNumberField.delegate = self
        expirationDate.delegate = self
        cvvField.delegate = self
        
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        //adjusting for incorrect string displayed in textField
        var fieldString = textField.text! + string
        if string == "" {
            //adjust for incorrect substringing when hitting back key.
            fieldString = fieldString.substringToIndex(fieldString.endIndex.advancedBy(-1))
        }
        
        //MARK: CardNumber Field
        if textField == cardNumberField {
            //let's see what card Types are possible with the input number
            let cardTypes = BTUICardType.possibleCardTypesForNumber(fieldString)
            //if the array is not empty and it only contains one number, let's set the card type. Otherwise set to false and change the color of the field
            if cardTypes.isEmpty == false && cardTypes.endIndex < 2 {
                if let card = cardTypes[0] as? BTUICardType {
                    cardHint.setCardType(cardRecognizer(card), animated: true)
                    cardHint.displayMode = BTCardHintDisplayMode.CardType
                    //format the strings in the entering field
                    let newString = card.formatNumber(textField.text)
                    textField.attributedText = newString
                    return fieldString.characters.count <= Int(card.maxNumberLength)
                }
            } else {
                cardHint.setCardType(.Unknown, animated: true)
                cardHint.displayMode = BTCardHintDisplayMode.CardType
                //disable input if > than 16 characters
                if (range.length + range.location > textField.text?.characters.count) {
                    return false
                }
                return fieldString.characters.count <= 16
            }
        }
        
        //MARK: CVV Field
        if textField == cvvField {
            
            //disable input if > 3 characters
            if (range.length + range.location > textField.text?.characters.count) {
                return false
            }
            return fieldString.characters.count <= 3
        }
        
        if textField == expirationDate {
            //if the count in the field is three and the input is a number, add a backslash
            if fieldString.characters.count == 3 && checkInt(string) {
                textField.text = textField.text! + "/"
            }
            return fieldString.characters.count <= 5
            
        }
        
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelButton(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func savePaymentType(sender: UIButton) {
        
        //TODO: Add activity indicator
        
        let tokenRequest = BTClientCardTokenizationRequest()
        //testvalues for number requests
//        tokenRequest.number = "4111111111111111"
//        tokenRequest.cvv = "421"
//        tokenRequest.expirationDate = "09/18"
        tokenRequest.number = cardNumberField.text!
        tokenRequest.cvv = cvvField.text!
        tokenRequest.expirationDate = expirationDate.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        //creating the client
        let BTclient = BTClient(clientToken: clientToken)
        //saves the card on server and receives a payment method nonce
        BTclient?.saveCardWithRequest(BTClientCardRequest(tokenizationRequest: tokenRequest), success: { (method) -> Void in
            let payment_method_nonce = method.nonce
            //payment method nonce gets submitted to server together with customerID
            self.client.callAPI(.PaymentMethod, parameters: self.client.paymentMethodParams(self.customerID!, payment_method_nonce: payment_method_nonce), completion: { (result, error) -> Void in
                if error != nil {
                    //handle error
                } else {
                    if let last_4 = result!["payment_method"]["last_4"].string {
                        if let token = result!["payment_method"]["token"].string {
                            if let card_type = result!["payment_method"]["card_type"].string {
                                let userRef = Firebase(url:"https://flashcash.firebaseio.com/users").childByAppendingPath(self.userId!).childByAppendingPath("Payment_Methods")
                                let cardInfo =
                                                [("number " + String(self.paymentNumber!)) :
                                                    ["lastFour":last_4,
                                                    "cardType":card_type,
                                                    "paymentToken":token,
                                                    "default":true]]
                                userRef.updateChildValues(cardInfo, withCompletionBlock: { (error, snapshot) -> Void in
                                    if error != nil {
                                        print(error)
                                    } else {
                                        print("successfully saved")
                                        self.dismissViewControllerAnimated(true, completion: nil)
                                    }
                                })
                            }
                        }
                    }
                }
            })
            }, failure: { (error) -> Void in
                print(error)
        })
    }
    
    func checkInt (string :String) -> Bool {
        let num = Int(string)
        return num != nil
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
