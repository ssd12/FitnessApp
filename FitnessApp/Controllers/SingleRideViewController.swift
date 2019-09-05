//
//  singleRideViewController.swift
//  BikeRideApp
//
//  Created by Simran Dhillon on 8/6/18.
//  Copyright © 2018 Simran Dhillon. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation
import UIKit
import os


class SingleRideViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var currentRide: SingleDistanceRide = SingleDistanceRide()
    var window: UIWindow?
    
    //buttons to start, stop, save, and reset ride
    @IBOutlet weak var startRideButton: UIButton!
    @IBOutlet weak var stopRideButton: UIButton!
    @IBOutlet weak var saveRideButton: UIButton!
    @IBOutlet weak var resetRideButton: UIButton!
    //labels
    @IBOutlet weak var elapsedTimeLabel: UILabel!
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var distanceTraveled: UILabel!
    @IBOutlet weak var totalDistanceLabel: UILabel!
    @IBOutlet weak var avgSpeedLabel: UILabel!
    //map related items
    @IBOutlet weak var singleRideMap: MKMapView!
    private var currentLocation: CLLocationCoordinate2D? = nil
    private var startLocation: CLLocationCoordinate2D? = nil
    private var stopLocation: CLLocationCoordinate2D? = nil
    private var locationManager = CLLocationManager()
    //sample coordinate
    var bostonCoord: CLLocationCoordinate2D? = CLLocationCoordinate2D(latitude: 42.3601, longitude: 71.0589)

    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Single Ride View Controller created")
        //add notification observers
        NotificationCenter.default.addObserver(self, selector: #selector(updateView), name: .distanceTraveledUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateView), name: .elapsedTimeUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateView), name: .avgSpeedUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateView), name: .totalTimeUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateView), name: .totalDistanceUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateView), name: .coordinatesUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateView), name: .updateDistance, object: nil)
       
        self.singleRideMap.delegate = self
        self.locationManager.allowsBackgroundLocationUpdates = true
        self.locationManager.activityType = .fitness
        let locAuthorizationStatus = CLLocationManager.authorizationStatus()
        print("\(locAuthorizationStatus.rawValue)")
        if locAuthorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        //if status is denied or restricted prompt message
        if locAuthorizationStatus == .denied || locAuthorizationStatus == .restricted {
            print(" Location Services Disabled")
        }
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        print("Location Mananger Properties Set up")
        startLocation = locationManager.location?.coordinate
        currentLocation = locationManager.location?.coordinate
        print("Start and current locations: \(startLocation.debugDescription) \(currentLocation.debugDescription)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //button actions
    @IBAction func startRidePressed(_ sender: UIButton) {
        currentRide.startRide()
        startLocation = locationManager.location?.coordinate
        os_log("Start Ride Pressed")
        getCurrentLocation()
    }
    
    //stops ride and sets total distance and total time to most recently completed ride values
    @IBAction func stopRidePressed(_ sender: UIButton) {
        currentRide.stopRide()
        totalTimeLabel.text  = String(currentRide.getRideTime())
        totalDistanceLabel.text = String(currentRide.totalDistance)
        avgSpeedLabel.text = String(currentRide.avgSpeed)
    }
    
    //Ride will be reset, i.e. timer will start from 0 sec, and distance will start from 0 m
    @IBAction func resetRidePressed(_ sender: UIButton) {
        currentRide.resetRide()
        updateView()
    }
    
    //updateView updates ride property views
    @objc func updateView() {
        print("Updating View")
        elapsedTimeLabel.text = String(currentRide.getElapsedTime())
        distanceTraveled.text = String(currentRide.elapsedDistance)
        totalTimeLabel.text  = String(currentRide.getRideTime())
        totalDistanceLabel.text = String(currentRide.totalDistance)
        avgSpeedLabel.text = String(currentRide.avgSpeed)
        getCurrentLocation()
        annotateMap()
    }
 
    //annotates map with annotation baloon and sets map region
    func annotateMap(){
        let mapCenter =  CLLocationCoordinate2D(latitude: currentLocation!.latitude, longitude: currentLocation!.longitude)
        _ = MKCoordinateRegion(center: mapCenter, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        let currentAnnotation = MKPointAnnotation()
        currentAnnotation.coordinate = currentLocation!
    }
    
    //updates total distance in single ride
    func updateDistance(_ startCoordinate : CLLocationCoordinate2D, _ stopCoordinate: CLLocationCoordinate2D) {
        currentRide.computeElapsedDistance(startCoordinate, stopCoordinate)
    }
    
    //When pressed saved ride buttons saves the most recent completed ride
    @IBAction func saveRidePressed(_ sender: UIButton) {
        self.currentRide.saveRide()
        os_log("Single Ride Stopped")
    }
    
    //use prepare func to pass currentRide object to savedRides VC
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("Sending currentRide object via segue")
        if segue.destination is SavedRidesViewController {
            let vc = segue.destination as? SavedRidesViewController
            vc?.currentRide = self.currentRide
        }
    }
    
    func getCurrentLocation(){
        print("Calling getCurrentLocation")
        currentLocation = locationManager.location?.coordinate
        if (currentRide.positionChanged(startLocation!, currentLocation!)) {
            updateDistance(startLocation!, currentLocation!)
            startLocation = currentLocation
            let mapCenter =  CLLocationCoordinate2D(latitude: currentLocation!.latitude, longitude: currentLocation!.longitude)
            let region = MKCoordinateRegion(center: mapCenter, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            singleRideMap.setRegion(region, animated: true)
            let currentAnnotation = MKPointAnnotation()
            currentAnnotation.coordinate = currentLocation!
            currentAnnotation.title = "Here"
            singleRideMap.addAnnotation(currentAnnotation)
        }
    }
    
}

