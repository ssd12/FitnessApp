//
//  Tests.swift
//  Tests
//
//  Created by Simran Dhillon on 9/10/19.
//  Copyright © 2019 Simran Dhillon. All rights reserved.
//

import XCTest

@testable import FitnessApp
class Tests: XCTestCase {

    let networkManager = NetworkManager.shared
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        print("setting up tests")
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
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
    
    func testValidUserLogin() {
        let parameters = ["username":"ssdd", "password":"password"]
        networkManager.sendRequest(parameters, .userLogin)
    }
    
    func testInvalidUserLogin() {
        let parameters = ["username":"dne", "password":"passwordwrong"]
        
    }
    
    func testValidUserLogout() {
        
    
    }
    
    //assuming there is no internet connection
    func invalidUserLogout() {
        
    }
}
