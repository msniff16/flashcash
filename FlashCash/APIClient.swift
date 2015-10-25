//
//  APICallsHelper.swift
//  FlashCash
//
//  Created by Julius Danek on 10/21/15.
//  Copyright © 2015 FlashCash. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class APIClient {
    
    let baseAPI = "http://flash-cash.herokuapp.com/api/v1/braintree/"
    
    func callAPI (endpoint: callTypes, parameters: [String: AnyObject], completion: (result: JSON?, error: NSError?) -> Void) {
        
        //converting to rawValue, i.e. string
        let stringEndpoint = endpoint.rawValue
        
        //sending out the request with parameters and the specified endpoints
        Alamofire.request(.POST, baseAPI + stringEndpoint, parameters: parameters, encoding: ParameterEncoding.URL, headers: nil).response { request, response, data, error in
                let responseData = JSON(data: data!)
                completion(result: responseData, error: error)
        }
    }
    
    //MARK: Parameter functions
    
//    func merchantAccountParams () -> [String: AnyObject] {
//        
//        
//    }
    
    func clientTokenParams (customerID: String) -> [String: AnyObject] {
        return ["customer_id": customerID]
    }
    
    func customerParams (first_name: String, last_name: String, email: String, phone: String) -> [String: AnyObject] {
        let dict = [
            "first_name": first_name,
            "last_name" : last_name,
            "email" : email,
            "phone" : phone
        ]
        return dict
    }
    
    func paymentMethodParams (customerID: String, payment_method_nonce: String) -> [String: AnyObject] {
        let dict = [
            "customer_id" : customerID,
            "payment_method_nonce" : payment_method_nonce
        ]
        return dict
    }
    
    func transactionParams (transactionID: String) -> [String: AnyObject] {
        let dict = [
            "transaction_id" : transactionID
        ]
        return dict
    }
    
    func saleParams (amount: String, token: String, fee_amount: String, customerID: String, merchantID: String) -> [String: AnyObject] {
        let dict = [
            "amount" : amount,
            "payment_method_token": token,
            "service_fee_amount" : fee_amount,
            "customer_id" : customerID,
            "merchant_account_id" : merchantID,
            "options" : [
                "submit_for_settlement" : false,
                "hold_in_escrow" : true
            ]
        ]
        return dict as! [String : AnyObject]
    }
    
    //Singleton
    
    class func sharedInstance() -> APIClient {
        
        struct Singleton {
            static var sharedInstance = APIClient()
        }
        return Singleton.sharedInstance
    }
    
    //enum containing the types of calls we have
    internal enum callTypes: String {
        case CustomerID = "customers"
        case ClientToken = "client_tokens"
        case MerchantAccount = "merchant_accounts"
        case PaymentMethod = "payment_methods"
        //TODO: These four functions need to be updated to their final endpoints
        case Void = "transaction/voids"
        case Release = "transaction/releases_from_escrow"
        case Settle = "transaction/submit_for_settlements"
        case Sale = "transaction/sales"
    }
}


