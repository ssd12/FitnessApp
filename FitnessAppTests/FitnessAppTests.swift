//
//  BikeRideAppTests.swift
//  BikeRideAppTests
//
//  Created by Simran Dhillon on 8/1/18.
//  Copyright © 2018 Simran Dhillon. All rights reserved.
//

import XCTest
import CoreLocation
@testable import BikeRideApp

class BikeRideAppTests: XCTestCase {
    
    var singleRide = SingleDistanceRide()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testResetRide() {
        singleRide.startRide()
        sleep(10)
        singleRide.startRide()
        singleRide.resetRide()
        let timeElapsed = singleRide.getRideTime()
        XCTAssertTrue(timeElapsed == 0.0)
        testSaveRide()
    }
    
    //saved a ride and check if DB objects has increased
    func testSaveRide() {
        var preSave = singleRide.getNumSavedRides()
        singleRide.startRide()
        singleRide.stopRide()
        singleRide.saveRide()
        var postSave = singleRide.getNumSavedRides()
        XCTAssertTrue(postSave > preSave)
        
        testElapsedDistance()
    }
    
    func testElapsedDistance() {
        //start and stop coordinates are lat-lon values for boston and providence
        var startLoc = CLLocationCoordinate2D(latitude: 41.8240, longitude: 71.4128)
        var stopLoc = CLLocationCoordinate2D(latitude: 42.3601, longitude: 71.0589)
        singleRide.startRide()
        sleep(20)
        singleRide.computeElapsedDistance(startLoc, stopLoc)
        singleRide.stopRide()
        //elapsed distance should be greater than 0.0 meters
        XCTAssertTrue(singleRide.totalDistance > 0.0)
    }
 
    
    
    
    
    
    
    
    
    
    
    
    
    
    func testLocationModelDistanceCalculation() {
        var locationModel = Location()
        //location 1 is the coordinate pair for nyc
        let location1 = CLLocation(latitude: CLLocationDegrees(exactly: 40.7128)!, longitude: CLLocationDegrees(74.0060))
        //location 2 is the coordinate pair for boston
        let location2 = CLLocation(latitude: CLLocationDegrees(42.3602), longitude: CLLocationDegrees(71.0589))
        var locationList = [location1, location2, location1]
        let distance = locationModel.calcTotalDistance(of: locationList)
        print("Location List total distance calc: \(distance)")
        
    }
    
    let networkUtils = NetworkUtils()
    
    func testCorrectUserLogin() {
        let parameters = ["username":"user1", "password":"pwd"]
        networkUtils.sendRequest(parameters, .userLogin)
    }
    
    func testIncorrectPasswordLogin() {
        let parameters = ["username":"user1", "password":"password"]
    }
   
    
}
