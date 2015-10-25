//
//  StartSearchViewController.swift
//  FlashCash
//
//  Created by Matthew Sniff on 10/21/15.
//  Copyright © 2015 FlashCash. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase
import GeoFire
import SwiftSpinner

class StartSearchViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet var mapView: MKMapView!
    var requestedPayment: String?
    @IBOutlet var paymentLabel: UILabel!
    @IBOutlet var cardNumber: UIButton!
    @IBOutlet var feeLabel: UILabel!
    @IBOutlet weak var moneyRequested: UILabel!
    
    var userId: String?
    var userEmail: String?
    var customerID: String?
    var currentLocation: CLLocation?
    var seguing: Bool?
    var seguing2: Bool?
    var locationSet: Bool?
    
    var runner_id: String?
    
    var defaultPayment: NSDictionary!
    
    var feeAmount: Float?
    
    var transactionID: String?
    
    private var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        mapView.delegate = self
        mapView.showsUserLocation = true
        self.seguing = false
        self.seguing2 = false
        self.locationSet = false
        
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.startUpdatingLocation()
        
        // user credz
        Auth.authorize() { (userEmail, userID, customerID, error) -> Void in
            if error != nil {
                //handle error
            } else {
                self.userEmail = userEmail
                self.userId = userID
                self.customerID = customerID
            }
        }
        
        

        // set payment label if there
        if let payment = requestedPayment {
            moneyRequested.text = "$ \(payment)"
            feeAmount = (Float(5) + (Float(payment)! * 0.02))
            feeLabel.text = "$ \(feeAmount!) Fee"
            paymentLabel.text = "$ \(feeAmount! + Float(payment)!)"
        }

        
    }
    
    // can't get current user location
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("didFailWithError: \(error.description)")
        print("Failed to Get Your Location")
    }
    
    // user has new location, set location in firebase
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
        currentLocation = locations.last!
        
        
        // set user location
        if(self.userId != nil && locationSet == false) {
            locationSet = true
            let geofireRef = Firebase(url: "https://flashcash.firebaseio.com/locations")
            let geoFire = GeoFire(firebaseRef: geofireRef)
            geoFire.setLocation(currentLocation!, forKey: self.userId!)
            print("current position: \(currentLocation!.coordinate.longitude) , \(currentLocation!.coordinate.latitude)")
            
            // your runner accepted request
            let customerRef = Firebase(url:"https://flashcash.firebaseio.com/users").childByAppendingPath(self.userId!)
            customerRef.observeEventType(.ChildChanged, withBlock: { (snapshot1) -> Void in
                customerRef.observeEventType(.Value, withBlock: { snapshot in
                    if let methods = snapshot.value["Payment_Methods"] as? [String: AnyObject] {
                        for (key, value) in methods {
                            let valueDict = value as! NSDictionary
                            for (key1, value1) in valueDict {
                                if key1 as! String == "default" && value1 as! NSObject == true {
                                    self.defaultPayment = valueDict as! NSDictionary
                                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                        self.cardNumber.setTitle(("Card ending in " + (self.defaultPayment["lastFour"] as! String)), forState: .Normal)
                                    })
                                }
                            }
                        }
                    }
                    
                    var request = snapshot.value.objectForKey("requestAccepted") as! Bool
                    print(request)
                    let newRun = snapshot.value.objectForKey("yourRunner") as? String
                    print(newRun)
                    if (request == true && newRun != nil && newRun != "") {
                        self.seguing = true
                    }

                    if(self.seguing == true && self.seguing2 == false) {
                        self.seguing = false
                        self.seguing2 = true
                        print("seguing: " + String(self.seguing))
                        print("seguing2: " + String(self.seguing2))
                        // go to waiting screen
                        if let runnerID = snapshot.value.objectForKey("yourRunner") as? String {
                            self.runner_id = runnerID
                            let merchantRef = Firebase(url: "https://flashcash.firebaseio.com/users").childByAppendingPath(runnerID)
                            merchantRef.observeEventType(.Value, withBlock: { snapshot in
                                let merchantID = snapshot.value.objectForKey("merchant_id") as! String
                                let client = APIClient.sharedInstance()
                                //TODO: Change the hard coded values
                                print(String(self.feeAmount!))
                                let params = client.saleParams(self.requestedPayment!, token: self.defaultPayment["paymentToken"] as! String, fee_amount: String(self.feeAmount!), customerID: self.customerID! , merchantID: merchantID)
                                client.callAPI(.Sale, parameters: params, completion: { (result, error) -> Void in
                                    if error != nil {
                                        print(error)
                                    } else {
                                        print(result)
                                        self.transactionID = result!["transaction"]["id"].string
                                        //TODO: Get the right transaction ID
                                        print(self.transactionID)
                                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                            SwiftSpinner.hide()
                                        })
                                        self.performSegueWithIdentifier("searchToWaiting", sender: nil)
                                    }
                                })
                                
                            })
                        }
                        
                    }
                })
                
            })
        }
        
       
        
    }
    
    // start search and send request to runner
    @IBAction func submitRequest(sender: UIButton) {
        
        SwiftSpinner.show("Finding runners...")
        
        // find runners
        let geofireRef = Firebase(url: "https://flashcash.firebaseio.com/runnerLocations")
        let geoFire = GeoFire(firebaseRef: geofireRef)
        let runnerQuery = geoFire.queryAtLocation(currentLocation, withRadius: 1.0)

        let queryHandle = runnerQuery.observeEventType(GFEventTypeKeyEntered, withBlock: { (key: String!, location: CLLocation!) in
            
            // found user
            if(key != nil) {
                
                print("Key '\(key)' entered the search area and is at location '\(location)'")
                
                // update runner information
                let runnerRef = Firebase(url:"https://flashcash.firebaseio.com/users").childByAppendingPath(key)
                let requestSent = ["requestSent": true]
                let requestFrom = ["requestFrom": self.userId!]
                runnerRef.updateChildValues(requestSent)
                runnerRef.updateChildValues(requestFrom)
        
                
            } else {
                let alert = UIAlertController(title: "No Runners Found", message: "Please try again soon!", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            
        })
        
    }
    
    // segue to next screen
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        if (segue.identifier == "registerToCashScreen") {
            
            if let cashVC = segue.destinationViewController as? CashViewController {
                
            }
        }
        
        if (segue.identifier == "searchToWaiting") {
            
            if let waitingViewController = segue.destinationViewController as? WaitingViewController {
                waitingViewController.transactionID = self.transactionID
                waitingViewController.runnerId = runner_id!
                
                
                // set waiting VC vars here
                // waitingViewController.runnerId = sender[0] as? String
                // waitingViewController.runnerLocation = sender[1] as? CLLocation
                
            }
        }
    }
    


}
