//
//  StartWorkVC.swift
//  FlashCash
//
//  Created by Julius Danek on 10/21/15.
//  Copyright © 2015 FlashCash. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase
import GeoFire

class StartWorkVC: UIViewController, CLLocationManagerDelegate {

    //TODO: Here we need the user credentials in order to change their status from active to inactive and to assign them the amount they are going to be carrying with them. The startWork button will bring them online. 
    
    @IBOutlet weak var amountField: UITextField!
    
    private var locationManager = CLLocationManager()
    
    var userId: String?
    var userEmail: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            }
        }
        
    }

    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        print("didFailWithError: \(error.description)")
        print("Failed to Get Your Location")
    }
    
    // user has new location, set location in firebase
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        
        let newLocation = locations.last!
        
        // set user location
        if(self.userId != nil) {
            let geofireRef = Firebase(url: "https://flashcash.firebaseio.com/runnerLocations")
            let geoFire = GeoFire(firebaseRef: geofireRef)
            geoFire.setLocation(newLocation, forKey: self.userId!)
            print("current position: \(newLocation.coordinate.longitude) , \(newLocation.coordinate.latitude)")
        }
        
    }
    
    // find any open requests sent to you
    @IBAction func startWork(sender: UIButton) {
        performSegueWithIdentifier("workToMerchant", sender: nil)
    }
}
