//
//  FreeRideViewModel.swift
//  BikeRideApp
//
//  Created by Simran Dhillon on 6/2/19.
//  Copyright © 2019 Simran Dhillon. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import CoreLocation
import Alamofire

class FreeRideViewModel: ReactiveCompatible {
    
    private(set) var totalDistance: Double = 0.0
    private(set) var totalTime: Double = 0.0
    private(set) var currentSpeed: Double = 0.0
    private(set) var location: Location = Location()
    private(set) var bag: DisposeBag = DisposeBag()
    private(set) var stopWatch: Stopwatch = Stopwatch()
    private(set) var currentLocation: CLLocation
    private(set) var activityInSession: Bool = false
    
    private(set) var activityAddedObservable: BehaviorSubject<Bool> = BehaviorSubject(value: false)
    
    init() {
        currentLocation = self.location.defaultLocationValue
        
    }
    
    func startRide() {
        location.subscribeToLocation()
        stopWatch.startStopWatch()
        let distanceUpdateSubscription = location.totalDistance.subscribe(onNext: totalDistanceObserved(_:), onError: handleObserverError(_:), onCompleted: handleObserverCompletion, onDisposed: handleObserverDisposal)
        let stopwatchUpdateSubscription = stopWatch.elapsedTimeSubject.subscribe(onNext: timeElapsedObserved(_:), onError: handleObserverError(_:), onCompleted: handleObserverCompletion, onDisposed: handleObserverDisposal)
        let locationUpdateSubscription = location.locationCoordinates.subscribe(onNext: locationUpdateObserved(_:), onError: handleObserverError(_:), onCompleted: handleObserverCompletion, onDisposed: handleObserverDisposal)
        activityInSession = true
    }
    
    private func setSubscriptions() {
        let activityAddedSubscription = ObserverService.shared.userActiviyAddedSuccessful.subscribe(
            onNext: { (activityAdded: Bool) -> Void in if (activityAdded) { self.activityAddedObservable.onNext(true)} },
            onError: { (error: Error) -> Void in print(error) },
            onCompleted: {},
            onDisposed: { ObserverService.shared.disposeBag.insert(ObserverService.shared.userActiviyAddedSuccessful) })
    }
    
    private func totalDistanceObserved(_ distance: Double) {
        print("Total distance observable value: \(distance)")
        totalDistance = metersToMiles(distance)
        NotificationCenter.default.post(name: .freeRideDistanceUpdated, object: nil)
    }
    
    private func timeElapsedObserved(_ time: Double) {
        print("Time Elapsed so far: \(time)")
        totalTime = time
        NotificationCenter.default.post(name: .elapsedTimeUpdated, object: nil)
    }
    
    private func locationUpdateObserved(_ location: CLLocation) {
        print("location udpate: \(location.coordinate)")
        currentLocation = location
        NotificationCenter.default.post(name: .locationUpdate, object: nil)
    }
    
    private func metersToMiles(_ distanceToConvert: Double) -> Double {
        let distanceInMiles = (distanceToConvert/1609.34)
        return ( Double(round(10*distanceInMiles)/10))
    }
    
    func getAverageSpeed() -> Double {
        let speed = totalDistance/(totalTime)
        return speed/3600
    }
    
    private func handleObserverError(_ error: Error) {
        print("Error while observing distance or time")
    }
    
    private func handleObserverCompletion() {
        print("Distance observed")
    }
    
    private func handleObserverDisposal() {
        print("Observable disposed")
    }
    
    func stopRide() {
        print("Stop Ride Pressed")
        stopWatch.stopStopWatch()
        location.stopLocationUpdates()
        NotificationCenter.default.post(name: .rideStopped, object: nil)
        activityInSession = false
    }
    
    func resetRide() {
        print("Reset Ride Pressed")
        stopWatch.resetRide()
        NotificationCenter.default.post(name: .rideReset, object: nil)
        activityInSession = false
    }
    
    func pauseRide() {
        print("Pause Ride Pressed")
        stopWatch.pauseStopWatch()
        location.stopLocationUpdates()
        NotificationCenter.default.post(name: .ridePaused, object: nil)
        activityInSession = false
    }
    
    func saveRide(_ activityType: String) {
        print("Save Ride Pressed")
        let timestamp = Date()
        print("timestamp description: \(timestamp.description)")
        let activityID = timestamp.description
        let parameters = ["activityID":activityID,"activityType":activityType,"distance":String(totalDistance),"time": String(totalTime),"username":UserDefaults.standard.object(forKey: "username") as? String ?? ""]
        NetworkManager.shared.sendRequest(parameters, .addNewActivity)
        NotificationCenter.default.post(name: .rideSaved, object: nil)
    }
}

extension Notification.Name {
    static let freeRideDistanceUpdated = Notification.Name("freeRideDistanceUpdated")
    static let rideStarted = Notification.Name("rideStarted")
    static let rideStopped = Notification.Name("rideStopped")
    static let rideReset = Notification.Name("rideReset")
    static let ridePaused = Notification.Name("ridePaused")
    static let rideSaved = Notification.Name("rideSaved")
    static let stopwatchTimeUpdated = Notification.Name("stopwatchTimeUpdated")
    static let locationUpdate = Notification.Name("locationUpdate")
}
