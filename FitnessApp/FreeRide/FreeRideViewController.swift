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

final class FreeRideViewController: UIViewController, MKMapViewDelegate {
    
    private var freeRideViewModel = FreeRideViewModel()
    
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
            self.freeRideViewModel.resetRide()
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
        let activityAdditionSubscription = freeRideViewModel.activityAddedObservable.subscribe(
            onNext: { (activityAdded: Bool) -> Void in if (activityAdded) {AlertToast.show(message: "User Activity Added", controller: self)} },
            onError: { (error: Error) -> Void in AlertToast.show(message: "Error adding user activity", controller: self)},
            onCompleted: {},
            onDisposed: {self.freeRideViewModel.bag.insert(self.freeRideViewModel.activityAddedObservable)})
    }
    
    
    @objc func savedRidesPressed() {
        print("Selector pressed")
        if (freeRideViewModel.activityInSession) {
            freeRideViewModel.pauseRide()
            activityExitAlert("Activity stopped. Continue to Saved Rides screen or press start to resume activity.")
        } else {
            let savedWorkoutsVC = SavedWorkoutsViewController()
            navigationController?.pushViewController(savedWorkoutsVC, animated: true)
        }
    }
  
    @IBAction func startButtonPressed(_ sender: Any) {
        freeRideViewModel.startRide()
    }
    
    @IBAction func stopButtonPressed(_ sender: Any) {
        freeRideViewModel.stopRide()
    }
    
    @IBAction func pauseButtonPressed(_ sender: Any) {
        freeRideViewModel.pauseRide()
    }
    
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        if (freeRideViewModel.activityInSession){
            freeRideViewModel.pauseRide()
            activityExitAlert("Activity Stopped. Close alert and save ride, or resume activity.")
        } else {
            freeRideViewModel.saveRide(activityType)
        }
    }
    
    @objc func distanceUpdate() {
        print("Updating distance")
        totalDistanceLabel.text = String(freeRideViewModel.totalDistance)
    }
    
    @objc func stopwatchTimeUpdate() {
        print("Updating time")
        timeLabel.text = String(freeRideViewModel.totalTime)
    }
    
    @objc func locationUpdate(){
        print("Updating location")
        print("Location: \(freeRideViewModel.currentLocation.coordinate)")
        annotateMap(freeRideViewModel.currentLocation.coordinate)
    }
    
    @objc func rideStopped() {
        let speed = String(format: "%.2f", freeRideViewModel.getAverageSpeed())
        speedLabel.text = speed
    }
    
    @objc func exitPage() {
        if (freeRideViewModel.activityInSession){
            freeRideViewModel.pauseRide()
            activityExitAlert("Activity stopped. Continue to Activity Selection screen or press start to resume activity.")
        } else {
            freeRideViewModel.stopRide()
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
