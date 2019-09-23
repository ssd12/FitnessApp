//
//  FreeRideViewController.swift
//  BikeRideApp
//
//  Created by Simran Dhillon on 6/2/19.
//  Copyright © 2019 Simran Dhillon. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation

final class ActivityViewController: UIViewController, MKMapViewDelegate {
    
    private var activityViewModel = ActivityViewModel()
    
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var totalDistanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    var activityType: String = ""
    
    override func viewDidLoad() {
        print("Created Free Ride View Controller")
        mapView.delegate = self
        setupNavBar()
        setupViews()
    }
    
    private func setupViews() {
        resetButton.rx.tap.bind {
            self.activityViewModel.resetRide()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(distanceUpdate), name: .freeRideDistanceUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(stopwatchTimeUpdate), name: .elapsedTimeUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(locationUpdate), name: .locationUpdate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(stopwatchTimeUpdate), name: .rideReset, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(rideStopped), name: .rideStopped, object: nil)
    }
    
    private func setupNavBar() {
        self.navigationController?.visibleViewController?.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Saved Rides", style: .plain, target: self, action: #selector(savedRidesPressed))
        self.navigationController?.visibleViewController?.navigationItem.title = "Free Ride"
        
        self.navigationController?.visibleViewController?.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Activity Screen", style: .plain, target: self, action: #selector(exitPage))
        self.navigationController?.navigationBar.isHidden = false
    }
    
    private func setupSubscriptions() {
        let activityAdditionSubscription = activityViewModel.activityAddedObservable.subscribe(
            onNext: { (activityAdded: Bool) -> Void in if (activityAdded) { print("Activity Added")}},
            onError: { (error: Error) -> Void in print(error)},
            onCompleted: {},
            onDisposed: {self.activityViewModel.bag.insert(self.activityViewModel.activityAddedObservable)})
    }
    
    @objc func savedRidesPressed() {
        print("Selector pressed")
        if (activityViewModel.activityInSession) {
            activityViewModel.pauseRide()
            activityExitAlert("Activity stopped. Continue to Saved Rides screen or press start to resume activity.")
        } else {
            let savedWorkoutsVC = SavedActivitiesViewController()
            navigationController?.pushViewController(savedWorkoutsVC, animated: true)
        }
    }
  
    @IBAction func startButtonPressed(_ sender: Any) {
        activityViewModel.startRide()
    }
    
    @IBAction func stopButtonPressed(_ sender: Any) {
        activityViewModel.stopRide()
    }
    
    @IBAction func pauseButtonPressed(_ sender: Any) {
        activityViewModel.pauseRide()
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        if (activityViewModel.activityInSession){
            activityViewModel.pauseRide()
            activityExitAlert("Activity Stopped. Close alert and save ride, or resume activity.")
        } else {
            activityViewModel.saveRide(activityType)
        }
    }
    
    @objc func distanceUpdate() {
        print("Updating distance")
        totalDistanceLabel.text = String(activityViewModel.totalDistance)
    }
    
    @objc func stopwatchTimeUpdate() {
        print("Updating time")
        timeLabel.text = String(activityViewModel.totalTime)
    }
    
    @objc func locationUpdate(){
        print("Updating location")
        print("Location: \(activityViewModel.currentLocation.coordinate)")
        annotateMap(activityViewModel.currentLocation.coordinate)
    }
    
    @objc func rideStopped() {
        let speed = String(format: "%.2f", activityViewModel.getAverageSpeed())
        speedLabel.text = speed
    }
    
    @objc func exitPage() {
        if (activityViewModel.activityInSession){
            activityViewModel.pauseRide()
            activityExitAlert("Activity stopped. Continue to Activity Selection screen or press start to resume activity.")
        } else {
            activityViewModel.stopRide()
            navigationController?.popViewController(animated: true)
        }
    }
    
    private func annotateMap(_ coordinate: CLLocationCoordinate2D) {
        print("Annotating map ")
        var mapRegion = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.setRegion(mapRegion, animated: true)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "Here"
        mapView.addAnnotation(annotation)
    }
    
    private func activityExitAlert(_ message: String) {
        let activityExitAlert = UIAlertController(title: "Exit Activity?", message: message, preferredStyle: .alert)
        activityExitAlert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
        self.present(activityExitAlert, animated: true)
    }
}
