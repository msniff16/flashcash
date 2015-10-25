//
//  Auth.swift
//  FlashCash
//
//  Created by Matthew Sniff on 10/21/15.
//  Copyright © 2015 FlashCash. All rights reserved.
//

import Foundation
import Firebase

class Auth {
    
    class func authorize(completionHandler: (userEmail: String?, userID: String?, customerID: String?, error: NSError?) -> Void) {
        
        // Get a reference to our posts
        let ref = Firebase(url:"https://flashcash.firebaseio.com")
    
        ref.observeAuthEventWithBlock({ authData in
            if authData != nil {
                
                    // user authenticated --> grab their data
                    let userId = authData.uid as NSString as String
                    let newRef = ref.childByAppendingPath("users").childByAppendingPath(authData.uid!)
                    newRef.observeEventType(.Value, withBlock: { snapshot in
                        let userEmail = snapshot.value.objectForKey("email") as! String
                        var customerID: String?
                        if let ID  = snapshot.value.objectForKey("customer_id") as? String {
                            customerID = ID
                        }
                        completionHandler(userEmail: userEmail, userID: userId, customerID: customerID, error: nil)
                })
                
            }
        })

        
    }
        
}
