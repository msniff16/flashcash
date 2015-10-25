//
//  MerchantMapVC.swift
//  FlashCash
//
//  Created by Julius Danek on 10/23/15.
//  Copyright © 2015 FlashCash. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase
import GeoFire
import MapKit

class MerchantMapVC: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    var userId: String?
    var userEmail: String?
    var customer: String?
    
    var defaultPayment: NSDictionary!


    override func viewDidLoad() {
        super.viewDidLoad()
        
        // user credz
        Auth.authorize() { (userEmail, userID, customerID, error) -> Void in
            if error != nil {
                //handle error
            } else {
                self.userEmail = userEmail
                self.userId = userID
                
                // check if you have any open requests being sent
                let ref = Firebase(url:"https://flashcash.firebaseio.com/users").childByAppendingPath(self.userId!)
                ref.observeEventType(.Value, withBlock: { snapshot in
                    let requestSent = snapshot.value.objectForKey("requestSent") as? Bool
                    
                    // has an open request
                    if let _ = requestSent {
                        
                        if(requestSent == true) {
                            self.customer = snapshot.value.objectForKey("requestFrom") as? String
                            
                            let alert = UIAlertController(title: "Cash Request", message: "Someone near you is in need of cash!", preferredStyle: UIAlertControllerStyle.Alert)
                            alert.addAction(UIAlertAction(title: "Accept", style: UIAlertActionStyle.Default, handler: self.acceptRequest))
                            alert.addAction(UIAlertAction(title: "Deny", style: UIAlertActionStyle.Default, handler: self.denyRequest))
                            self.presentViewController(alert, animated: true, completion: nil)

                        }
               
                    }
                    
                })
                
            }
        }
        

    }
    
    // request accepted
    func acceptRequest(alert: UIAlertAction!) {
        // update runner information to set requestSent
        let customerRef = Firebase(url:"https://flashcash.firebaseio.com/users").childByAppendingPath(customer!)
        let requestAccepted = ["requestAccepted": true]
        let runnerId = ["yourRunner": self.userId!]
        customerRef.updateChildValues(requestAccepted)
        customerRef.updateChildValues(runnerId)
        
        // take me to google maps
        let geofireRef = Firebase(url: "https://flashcash.firebaseio.com/locations")
        let geoFire = GeoFire(firebaseRef: geofireRef)
        geoFire.getLocationForKey(customer!, withCallback: { (location, error) in
            if (error != nil) {
                print("An error occurred getting the location for \"firebase-hq\": \(error.localizedDescription)")
            } else if (location != nil) {
                
                let latitute:CLLocationDegrees =  location.coordinate.latitude
                let longitute:CLLocationDegrees =  location.coordinate.longitude
                
                let regionDistance:CLLocationDistance = 10000
                let coordinates = CLLocationCoordinate2DMake(latitute, longitute)
                let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
                let options = [
                    MKLaunchOptionsMapCenterKey: NSValue(MKCoordinate: regionSpan.center),
                    MKLaunchOptionsMapSpanKey: NSValue(MKCoordinateSpan: regionSpan.span)
                ]
                let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
                var mapItem = MKMapItem(placemark: placemark)
                mapItem.name = "Customer Location"
                mapItem.openInMapsWithLaunchOptions(options)
                
                
            } else {
                print("GeoFire does not contain a location for \"firebase-hq\"")
            }
        })
        
    }
    
    // request denied
    func denyRequest(alert: UIAlertAction!) {
        
        // update runner information to set requestSent
        let customerRef = Firebase(url:"https://flashcash.firebaseio.com/users").childByAppendingPath(self.userId!)
        let requestAccepted = ["requestFrom": ""]
        let runnerId = ["requestSent": false]
        customerRef.updateChildValues(requestAccepted)
        customerRef.updateChildValues(runnerId)

        
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
            let geofireRef = Firebase(url: "https://flashcash.firebaseio.com/locations")
            let geoFire = GeoFire(firebaseRef: geofireRef)
            geoFire.setLocation(newLocation, forKey: self.userId!)
            print("current position: \(newLocation.coordinate.longitude) , \(newLocation.coordinate.latitude)")
        }
        
    }

    // close request
    @IBAction func onCloseRequest(sender: UIButton) {
        
        // update runner information to set requestSent
        let customerRef = Firebase(url:"https://flashcash.firebaseio.com/users").childByAppendingPath(self.userId!)
        let requestAccepted = ["requestFrom": ""]
        let runnerId = ["requestSent": false]
        customerRef.updateChildValues(requestAccepted)
        customerRef.updateChildValues(runnerId)
        
        self.navigationController?.popViewControllerAnimated(true)
        
    }
    
    // accepted payment
    @IBAction func onAcceptPayment(sender: UIButton) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        
        
    }
}
