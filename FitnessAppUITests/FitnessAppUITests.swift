//
//  BikeRideAppUITests.swift
//  BikeRideAppUITests
//
//  Created by Simran Dhillon on 8/1/18.
//  Copyright © 2018 Simran Dhillon. All rights reserved.
//

import XCTest

class BikeRideAppUITests: XCTestCase {
    
    let application = XCUIApplication()
   
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        application.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    //Start tests by launching application and selecting single Ride
    func testSingleRideButton () {
        let singleRideButton = application.buttons["singleRideButton"]
        singleRideButton.tap()
        print("Tested Main Screen Single Ride selection button")
        testStartRideButton()
        testStopRideButton()
        testResetButton()
        testSaveRideButton()
        testExpandRideCell()
        testDeleteSwipeRideCell()
    }
    
    func testStartRideButton() {
        let startRideButton = application.buttons["startRideButton"]
        startRideButton.tap()
        print("Tested Single Ride Start Button")
    }
    
    func testStopRideButton() {
        let stopRideButton = application.buttons["stopRideButton"]
        stopRideButton.tap()
        print("Tested Singe Ride Stop Ride Button")
    }
    
    func testResetButton() {
        let resetRideButton = application.buttons["resetRideButton"]
        resetRideButton.tap()
        print("Tested Single Ride Reset Button")
    }
    
    func testSaveRideButton() {
        testStartRideButton()
        sleep(10)
        testStopRideButton()
        let savedRidesButton = application.buttons["savedRidesButton"]
        savedRidesButton.tap()
        print("Tested Single Ride Save Ride Button")
    }
    
    func testExpandRideCell() {
        let rideTable = application.tables.cells
        rideTable.element(boundBy: 0).tap()
        //check if Ride Details is open
        XCTAssert(application.staticTexts["Ride Details"].exists)
        print("Tested Saved Rides Table Cell Expansion")
    }
    
    func testDeleteSwipeRideCell() {
        let rideTable = application.tables.cells
        rideTable.element(boundBy: 0).swipeLeft()
        print("Tested Saved Rides Cell Left Swipe")
    }
    
    
    
}
