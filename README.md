# FlashCash
Request cash anytime, anywhere.
If you're in a spot when you need cash and don't want to search around for an ATM just to pay gross ATM fees, use FlashCash to have your cash delivered to your location right as you need it. 

## Tech Stack:

Back-end built in Firebase for real time observation of database changes.

Payments via Braintree / Paypal API using a server and open API built in Ruby

App built in Swift 

### Pods used:

* [GeoFire](https://github.com/firebase/geofire-objc)
* [BrainTree](https://github.com/braintree/braintree_ios)
* [SwiftyJson](https://github.com/SwiftyJSON/SwiftyJSON)
* [Alamofire](https://github.com/Alamofire/Alamofire)
* [SwiftSpinner](https://github.com/icanzilb/SwiftSpinner)

## Features:

Sign up either as a customer or a cash runner. 

### Customer:

* Add and edit payment methods
* Choose how much cash you want
* Request cash from runners around you - triggers transaction authorization and places transaction in escrow
* See waiting time
* Confirm payment - settles transaction and releases money from escrow
* Cancel payment - voids transaction

### Cash Runner:

* Sign up with your checking account for deposits - as a [BrainTree Market Place Merchant](https://developers.braintreepayments.com/guides/marketplace/overview)
* Indicate when you are ready to start work
* See a heatmap with customer concentration
* Pop-ups when customer requests money
* See routing to customer location once accepted
* Once delivery is confirmed, receive deposits in your accounts

## Demo
![flashcashdemo](https://cloud.githubusercontent.com/assets/1372815/10719930/c8de294c-7b4e-11e5-934c-84a067fb6e1d.gif)
