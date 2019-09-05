//
//  WorkoutRide.swift
//  BikeRideApp
//
//  Copyright © 2018 Simran Dhillon. All rights reserved.
//
// CoreMotion/Distance workout not implemented yet, assume all workouts are time based


import Foundation

class WorkoutRide: WorkoutRideProtocol {


    //default values set to 0 when class is initialized
    var numberOfSets: Int = 0
    var currentSet: Int = 0
    var workoutType: String = ""
    let splitTypes = ("distance","time")
    var sprintUnit: Double = 0.0
    var restUnit: Double = 0.0
    var totalUnits: Double {
        return sprintUnit+restUnit
    }
    var elapsedSprintUnits: Double = 0.0
    var elapsedRestUnits: Double = 0.0
    //notification center to update subscribers about state changes
    let notificationCenter: NotificationCenter
    var mostRecentWorkout: String = ""
    //mainTimer for workoutRide
    var mainTimer: Timer = Timer()
    
    
    
    init(notificationCenter: NotificationCenter = .default){
        self.notificationCenter = notificationCenter
    }
    
    func startRide() {
        print("Starting Workout")
        //call timer object each for the number of sets
        for s in 1...self.numberOfSets {
            self.currentSet = s
            //set values for sprintUnits and restUnit
            self.elapsedSprintUnits = self.sprintUnit
            self.elapsedRestUnits = self.restUnit
            mainTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateUnits), userInfo: nil, repeats: true)
        }
    }
    
    //updateUnits is called by the mainTimer
    @objc func updateUnits(){
        if (elapsedRestUnits > 0) {
            if (elapsedSprintUnits < 1) {
                self.elapsedSprintUnits = 0.0
                self.elapsedRestUnits = self.elapsedRestUnits - 0.1
            } else {
                self.elapsedSprintUnits = self.elapsedSprintUnits - 0.1
            }
        } else {
            elapsedRestUnits = 0.0
            mainTimer.invalidate()
        }
        //push notifications since either units elapsed or set have changed
        self.updateRide()
    }
    
    
    //stops timer
    func stopRide() {
        print("Stopping Ride")
        mainTimer.invalidate()
        print("Stopped Ride")
    }
    
    //sets everything back to 0
    func resetRide() {
        self.numberOfSets = 0
        self.sprintUnit = 0.0
        self.restUnit   = 0.0
        self.currentSet = 0
        print(" Notifying controller: ")
        notificationCenter.post(name: .workoutPropertiesUpdated, object: nil)
        print(" Controller notified of state changes")
    }
    
    
    func updateRide() {
        notificationCenter.post(name: .sprintUnitUpdated, object: nil)
        notificationCenter.post(name: .restUnitUpdated, object: nil)
        notificationCenter.post(name: .currentSetUpdated, object: nil)
    }
    
    func createMostRecentRide() -> String {
        return ""
    }
    
    func saveRide() {
        
    }
    
    //set/change the number of sets and send a notification
    func setNumberOfSets(_ num: Int) {
        self.numberOfSets = num
        self.currentSet = num
        print(" Notifying controller: ")
        notificationCenter.post(name: .workoutPropertiesUpdated, object: nil)
        print(" Controller notified of state changes")
    }
    
    func startWorkout() {
        
    }
    
    func stopWorkout() {
        
    }
    
}

//Three main state changes occur while the app is running:
// (1): The sprint units change, i.e. 10 sec, 9 sec, 8 sec, so on until sprint portion of workout is done
// (2): The rest units change, i.e. 5 sec, 4 sec, 3 sec, so on until rest period is over
// (3): Current workout set. As the user proceeds through the workout, he or she will change the current set he or she is on
// (4): Any workoutRide properties are changed, i.e. number of sets, rest, and sprint time/distance

extension Notification.Name {
    static let workoutPropertiesUpdated  = Notification.Name("workoutPropertiesUpdated")
    static let sprintUnitUpdated = Notification.Name("sprintUnitUpdated")
    static let restUnitUpdated = Notification.Name("restUnitUpdated")
    static let currentSetUpdated = Notification.Name("currentSetUpdated")
}
