//
//  SingleDistanceRide.swift
//  BikeRideApp
//  Copyright © 2018 Simran Dhillon. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation
import CoreData
import os

class SingleDistanceRide: SingleDistanceRideProtocol {
    
    //Ride Time variables:
    //time of complete ride
    private var rideTime: Double = 0.0
    //current time, i.e. time elapsed so far
    private var timeElapsed: Double = 0.0
    //timerOn is a boolean value to check whether timer running
    var timerOn = false
    //avgSpeed is the average speed for the singleDistance ride
    var avgSpeed: Double {
        return self.roundDouble(totalDistance/Double(rideTime))
    }
    //rideTimer is the timer object for the single distance ride
    var rideTimer = Timer()
    
    //Ride Distance variables
    //total distance of ride
    var totalDistance: Double = 0.0
    var elapsedDistance: CLLocationDistance = 0.0
    var coordinatesList: [String] = [String]()
    var coordinates: CLLocationCoordinate2D = CLLocationCoordinate2D()
    var locations: [CLLocationCoordinate2D] = [CLLocationCoordinate2D]()
    
    //persistence information
    //placeholder for the most recent ride to be saved
    var mostRecentRide: String = ""
    var savedRides: [NSManagedObject] = []
    
    init(){
        print("Single Distance Ride Model initialized")
    }
    
    //updates the time elapsed, called when timer is running during a ride
    @objc func updateTimeElapsed() {
        self.timeElapsed=self.timeElapsed+0.1
        self.timeElapsed = self.roundDouble(timeElapsed)
        print("Elapsed Time: \(timeElapsed)")
        sendRideNotificaitons()
    }
    
    //startRide starts the ride 
    func startRide(){
        //reset all values first
        self.resetRide()
        print("STARTING RIDE")
        self.rideTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(SingleDistanceRide.updateTimeElapsed), userInfo: nil, repeats: true)
        self.timerOn = true
    }
    
    //getRideTime returns the rideTime for last/most recent completed ride
    func getRideTime()-> Double {
        return self.rideTime
    }
    
    //stopRide stops the "ride", computes final single ride calculations
    func stopRide(){
        self.rideTime = self.timeElapsed
        self.totalDistance = self.elapsedDistance
        self.totalDistance = self.roundDouble(totalDistance)
        self.mostRecentRide = createRideInfo()
        self.rideTimer.invalidate()
        self.timerOn = false
        print("Most recent ride info: \(self.mostRecentRide)")
        print("Stopping Ride")
        print(coordinatesList)
        sendRideNotificaitons()
    }
    
    //resetRide sets elapsed time to 0, changes timer to false
    func resetRide(){
        self.timeElapsed = 0.0
        self.elapsedDistance = 0.0
        self.totalDistance = 0.0
        self.timerOn = false
        self.rideTime = 0.0
        print("Ride Reset")
    }
    
    //positionChanged checks if start and stop Coordinate locations are different
    func positionChanged(_ startCoord: CLLocationCoordinate2D, _ stopCoord: CLLocationCoordinate2D) -> Bool {
        print("Checking if position changed: ")
        print("StartCoordinate: \(startCoord.latitude) \(startCoord.longitude)")
        print("StopCoordinate: \(stopCoord.latitude) \(stopCoord.longitude)")
        if ((startCoord.latitude == stopCoord.latitude) && (startCoord.longitude == stopCoord.longitude)) {
            print("Position Not Changed")
            return false
        } else {
            print("Position Changed")
            return true
        }
    }
    
    //computeElapsedDistance computes the distance between start and stop coordinates, and adds to the elapsed ride distance
    func computeElapsedDistance(_ startCoord: CLLocationCoordinate2D, _ stopCoord: CLLocationCoordinate2D) {
        //convert coordinates to CLLocation values
        print("Computed Elapsed Distance")
        var startLocation = CLLocation(latitude: startCoord.latitude, longitude: startCoord.longitude)
        var stopLocation = CLLocation(latitude: stopCoord.latitude, longitude: stopCoord.longitude)
        print("Coordinates: \(startLocation.coordinate) \(stopLocation.coordinate)")
        self.elapsedDistance = self.elapsedDistance+(stopLocation.distance(from: startLocation))
        self.elapsedDistance = self.roundDouble(elapsedDistance)
        locations.append(startCoord)
        locations.append(stopCoord)
        print("Elapsed Distance: \(self.elapsedDistance)")
    }
    
    //saveRide saves the ride information to CoreData db
    func saveRide() {
        print("Saving Information")
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "SingleRide", in: context)!
        let ride = NSManagedObject(entity: entity, insertInto: context)
        ride.setValue(self.mostRecentRide, forKeyPath: "rideInfo")
        ride.setValue(self.genTimeStamp(), forKeyPath: "timeStamp")
        ride.setValue(String(self.totalDistance), forKeyPath: "distance")
        ride.setValue(String(self.rideTime), forKeyPath: "time")
        ride.setValue(String(self.avgSpeed), forKeyPath: "speed")
        do {
            try context.save()
            savedRides.append(ride)
            print("savedRides size: \(String(savedRides.count))")
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        print("Added to core data: \(self.mostRecentRide)")    }
    
    //creates a string representation of ride attributes that stores ride information
    func createRideInfo() -> String {
        let infoToReturn = String(self.totalDistance) + " meters" +  String(self.rideTime) + " sec"  + String(self.avgSpeed) + " m/s"
        return infoToReturn
    }
    
    //getLocationCoordinates returns the current coordinates
    func getLocationCoordinates() -> CLLocationCoordinate2D {
        return self.coordinates
    }
    
    //sendRideNotifications notifies the view controller
    func sendRideNotificaitons() {
        NotificationCenter.default.post(name: .elapsedTimeUpdated, object: nil)
        NotificationCenter.default.post(name: .totalDistanceUpdated, object: nil)
        NotificationCenter.default.post(name: .distanceTraveledUpdated, object: nil)
        NotificationCenter.default.post(name: .totalDistanceUpdated, object: nil)
        NotificationCenter.default.post(name: .totalTimeUpdated, object: nil)
        NotificationCenter.default.post(name: .avgSpeedUpdated, object: nil)
        NotificationCenter.default.post(name: .updateDistance, object: nil)
        print("Single Ride Notifications Sent")
    }
    
    //getElapsedTime returns elapsed time so far
    func getElapsedTime() -> Double {
        return self.timeElapsed
    }
   
    //genTimeStamp returns a string representation of the current time and date
    func genTimeStamp() -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy_MM_dd_hh_mm_ss"
        return (formatter.string(from: Date()) as NSString) as String
    }
    
    //roundDouble returns a double rounded to two decimal places
    func roundDouble(_ x: Double) -> Double {
        return Double(round(100*x)/100)
    }
    
    //getNumSavedRides returns the size of the NSManagedObject array of saved rides
    func getNumSavedRides() -> Int {
        print("Number of saved rides: \(savedRides.count)")
        return savedRides.count
    }
    
}

/*  Notifications are sent by the SingleDistanceRide Model to the SingleRideViewController
    Notifications are sent to notify controller of model state changes, i.e. time, distance, etc.
 */
extension Notification.Name {
    static let distanceTraveledUpdated = Notification.Name("distanceTraveledUpdated")
    static let elapsedTimeUpdated = Notification.Name("elapsedTimeUpdated")
    static let avgSpeedUpdated = Notification.Name("avgSpeedUpdated")
    static let totalTimeUpdated = Notification.Name("totalTimeUpdated")
    static let totalDistanceUpdated = Notification.Name("totalDistanceUpdated")
    static let coordinatesUpdated = Notification.Name("coordinatesUpdated")
    static let updateDistance = Notification.Name("updateDistance")
}



