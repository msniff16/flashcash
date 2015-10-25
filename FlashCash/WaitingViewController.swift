//
//  WaitingViewController.swift
//  FlashCash
//
//  Created by Matthew Sniff on 10/21/15.
//  Copyright © 2015 FlashCash. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation
import GeoFire
import SwiftSpinner

class WaitingViewController: UIViewController {
    
    let ref = Firebase(url: "https://flashcash.firebaseio.com")
    var userId: String?
    var userEmail: String?
    
    @IBOutlet var locationLabel: UILabel!
    var runnerId: String?
    var runnerLocation: CLLocation?
    var transactionID: String?
    
    var locationHere: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationHere = false
        
        // set runner location label
        if let runnerLocation = runnerLocation {
            locationLabel.text = "\(runnerLocation)"
        }
        
        // user credz
        Auth.authorize() { (userEmail, userID, customerID, error) -> Void in
            if error != nil {
                //handle error
            } else {
                self.userEmail = userEmail
                self.userId = userID
                
                // get runner information
                let newRef = self.ref.childByAppendingPath("users")
                    .childByAppendingPath(self.userId!)
                newRef.observeEventType(.Value, withBlock: { snapshot in
//                    self.runnerId = snapshot.value.objectForKey("yourRunner")! as? String
                    
                    // get runner's location
                    let geofireRef = Firebase(url: "https://flashcash.firebaseio.com/runnerLocations")
                    let geoFire = GeoFire(firebaseRef: geofireRef)
                    if self.locationHere == false {
                        geoFire.getLocationForKey(self.runnerId, withCallback: { (location, error) in
                            if (error != nil) {
                                print("An error occurred getting the location for \"firebase-hq\": \(error.localizedDescription)")
                            } else if (location != nil) {
                                self.locationHere = true
                                print("Location for \(self.runnerId) is [\(location.coordinate.latitude), \(location.coordinate.longitude)]")
                                self.locationLabel.text = "\(location.coordinate.latitude)"
                                self.runnerLocation = location
                            } else {
                                print("GeoFire does not contain a location for \"firebase-hq\"")
                            }
                        })
                    }

                    
                })

            }
        }
               
    }

    // delivery has been confirmed
    @IBAction func confirmDelivery(sender: AnyObject) {
        
        SwiftSpinner.show("Confirming Payment...")

        let locationRef = Firebase(url:"https://flashcash.firebaseio.com/users").childByAppendingPath(self.userId!)
        let request = ["requestAccepted": false]
        let yourRunner = ["yourRunner": ""]
        locationRef.updateChildValues(request)
        locationRef.updateChildValues(yourRunner)
        
        let customerRef = Firebase(url:"https://flashcash.firebaseio.com/users").childByAppendingPath(self.runnerId!)
        let request2 = ["requestSent": false]
        let yourRunner2 = ["requestFrom": ""]
        customerRef.updateChildValues(request2)
        customerRef.updateChildValues(yourRunner2)
        
        APIClient.sharedInstance().callAPI(.Settle, parameters: APIClient.sharedInstance().transactionParams(self.transactionID!)) { (result, error) -> Void in
            if error != nil {
                print(error)
            } else {
                print(result)
                APIClient.sharedInstance().callAPI(.Release, parameters: APIClient.sharedInstance().transactionParams(self.transactionID!), completion: { (result, error) -> Void in
                    if error != nil {
                        print(error)
                    } else {
                        print(result)
                        self.navigationController?.popToRootViewControllerAnimated(true)
                    }
                })
            }
        }
    }
    
    // set tracking to false in firebase
    @IBAction func stopMoney(sender: UIButton) {
        
        let locationRef = Firebase(url:"https://flashcash.firebaseio.com/users").childByAppendingPath(self.userId!)
        let request = ["requestAccepted": false]
        let yourRunner = ["yourRunner": ""]
        locationRef.updateChildValues(request)
        locationRef.updateChildValues(yourRunner)
        
        let customerRef = Firebase(url:"https://flashcash.firebaseio.com/users").childByAppendingPath(self.runnerId!)
        let request2 = ["requestSent": false]
        let yourRunner2 = ["requestFrom": ""]
        customerRef.updateChildValues(request2)
        customerRef.updateChildValues(yourRunner2)
        
        APIClient.sharedInstance().callAPI(.Void, parameters: APIClient.sharedInstance().transactionParams(self.transactionID!)) { (result, error) -> Void in
            if error != nil {
                print(error)
            } else {
                print(result)
                self.navigationController?.popToRootViewControllerAnimated(true)
            }
        }
        
    }

}
