//
//  Utilities.swift
//  BikeRideApp
//
//  Created by Simran Dhillon on 7/4/19.
//  Copyright © 2019 Simran Dhillon. All rights reserved.
//

/*  All units for distance in meters, for time in seconds, and for speed in meters per second
 
 */

import Foundation
import UIKit

final class Utilities {
    
    enum rideType {
        case freeRide
        case intervalRide(unitType: intervalRideUnitType)
    }
    
    enum intervalRideUnitType {
        case distance(workoutDistance: Double, restDistance: Double)
        case time(workoutTime: Double, restTime: Double)
    }
    
    enum screenType {
        case freeRideScreen
        case intervalRideScreen
        case savedRidesScreen
    }
    
    enum userLoginState: String {
        case loggedIn = "loggedIn"
        case loginError = "loginError"
        case loggedOut = "loggedOut"
    }
    
    enum securityQuestions: String {
        case pet = "What was the name of your first pet"
        case city = "What city or town were you born in?"
        case artist = "What is the name of your favorite artist"
    }
    
    enum activityType: String {
        case walk = "Walk"
        case bike = "Bike"
        case run = "Run"
    }
    
    enum ResponseType: String {
        case loginSuccessful = "loginSuccessful"
        case loginError = "loginError"
        case logoutSuccessful = "logoutSuccessful"
        case registrationSuccessful = "registrationSuccessful"
        case registrationError = "registrationError"
        case activityAdded = "activityAdded"
        case userDeleted = "userDeleted"
        case userActivitiesFetched = "userActivitiesFetched"
        case error = "error"
    }
}
