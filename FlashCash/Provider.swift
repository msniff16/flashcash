//
//  Provider.swift
//  FlashCash
//
//  Created by Julius Danek on 10/21/15.
//  Copyright © 2015 FlashCash. All rights reserved.
//

class Provider {
    
    // stores information about the provider as well as giving a method to create a dictionary suitable for submission into the API
    init (first_name: String, last_name: String, email: String, phone: String) {
        self.first_name = first_name
        self.last_name = last_name
        self.email = email
        self.phone = phone
    }
    
    // params
    var first_name: String
    var last_name: String
    var email: String
    var phone: String
    var tos_accepted = false
    var date_of_birth = ""
    var ssn = ""
    var street = ""
    var city = ""
    var state = ""
    var zip = ""
    var account_number = ""
    var routing_number = ""
    
    // This is for testing purposes
    convenience init () {
        
        self.init(first_name: "Julius", last_name: "Danek", email: "juliusdanek@gmail.com", phone: "6173522801")
        
        tos_accepted = true
        date_of_birth = "1991-05-08"
        ssn = "123-45-6789"
        street = "934 Howard Street"
        city = "San Francisco"
        state = "CA"
        zip = "94103"
        account_number = "1123581321"
        routing_number = "071101307"
    }
    
    // helper function to create the parameter dictionary needed for the API
    func createParamDict() -> [String:AnyObject] {
        
        let callDict = [
            "tos_accepted" : tos_accepted,
            "master_merchant_account_id" : "1234567890",
            "individual": [
                "first_name": first_name,
                "last_name" : last_name,
                "email" : email,
                "phone" : phone,
                "date_of_birth": date_of_birth,
                "ssn": ssn,
                "address": [
                    "street_address": street,
                    "locality": city,
                    "region": state,
                    "postal_code": zip
                ]
            ],
            "funding": [
                "descriptor" : "FlashCash",
                "destination" : "bank",
                "account_number" : account_number,
                "routing_number" : routing_number
            ]
        ]
        return callDict as! [String : AnyObject]
    }
}