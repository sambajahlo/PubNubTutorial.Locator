//
//  ViewController.swift
//  PubNub Tutorial
//
//  Created by Samba Diallo on 1/28/19.
//  Copyright © 2019 Samba Diallo. All rights reserved.
//

import UIKit
import PubNub // <- Here is our PubNub module import.
import MapKit
import CoreLocation

class ViewController: UIViewController, PNObjectEventListener, CLLocationManagerDelegate {


    let span =  MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    var locationManager: CLLocationManager!
    var askedForHelp = false
    let UUID = "UUID"
    //Getting San Francisco Coordinates
    let sanFrancisco = CLLocation(latitude: 37.7739, longitude: -122.4312)
    
    @IBOutlet weak var alertButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    // Stores reference on PubNub client to make sure what it won't be released.
    var client: PubNub!
    
    @IBAction func alert(_ sender: UIButton) {
        if(!askedForHelp){
           alertButton.setImage(UIImage(named: "finished"), for: .normal)
            //Tells location function that they still want their location broadcasted.
            askedForHelp = true
            //publishes their initial location
            publishLocation()
            //Put in ClickSend text function later
            self.okayAlert(title: "Alerted", message: "All contacts alerted to your location.")
        }else{
            alertButton.setImage(UIImage(named: "alert"), for: .normal)
            askedForHelp = false
        }
    }
    
    //This function sets up the locationManager to see where the users current location is.
    func setUpLocation(){
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 5
        locationManager.requestWhenInUseAuthorization()
        goToLocation(location: locationManager.location ?? sanFrancisco)
    }
    func getCurrentLocation()-> CLLocation{
        return locationManager.location ?? sanFrancisco
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first{
            let region = MKCoordinateRegion(center: location.coordinate,span: span)
            mapView.setRegion(region, animated: false)
            if(askedForHelp){
                publishLocation()
                
            }
        }
        
    }
    func goToLocation(location:CLLocation){
        let reigon = MKCoordinateRegion(center: location.coordinate,span: span)
        mapView.setRegion(reigon, animated: false)
    }
    func publishLocation(){
        let currentCoordinate = getCurrentLocation().coordinate
        let locationDict = [
            "lat": currentCoordinate.latitude,
            "lon": currentCoordinate.longitude
        ]
        self.client.publish(locationDict, toChannel: UUID) { (status) in
            if(!status.isError){
                print("SUCCESS sending location")
            }else{
                print(status)
            }
        }
    }
    
    
    
    func setUpPubNub(){
        // Initialize and configure PubNub client instance
        let configuration = PNConfiguration(publishKey: "INSERT PUBLISH KEY HERE", subscribeKey: "INSERT SUBSCRIBE KEY HERE")
        configuration.stripMobilePayload = false
        self.client = PubNub.clientWithConfiguration(configuration)
        self.client.addListener(self)
        
        // Subscribe to demo channel with presence observation
        self.client.subscribeToChannels([UUID], withPresence: true)
    }
    // Handle new message from one of channels on which client has been subscribed.
    func client(_ client: PubNub, didReceiveMessage message: PNMessageResult) {
        
        print("Received message: \(message.data.message ?? "default value") on channel \(message.data.channel) " +
            "at \(message.data.timetoken)")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpPubNub()
        setUpLocation()
        locationManager.startUpdatingLocation()
        alertButton.setImage(UIImage(named: "alert"), for: .normal)
        
        
    }
    func okayAlert(title: String,message : String){
        let alert = UIAlertController(title:title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    


}

