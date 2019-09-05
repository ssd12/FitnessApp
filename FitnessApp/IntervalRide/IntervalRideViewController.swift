//
//  IntervalRideViewController.swift
//  BikeRideApp
//
//  Created by Simran Dhillon on 7/9/19.
//  Copyright © 2019 Simran Dhillon. All rights reserved.
//

import Foundation
import UIKit


class IntervalRideViewController: UIViewController {
    
    override func viewDidLoad() {
        print("Created Interval Ride View Controller")
        setupNavBar()
    }
    
    private func setupNavBar() {
        navigationController?.visibleViewController?.navigationItem.title = "Interval Ride"
        navigationController?.visibleViewController?.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Saved Rides", style: .plain, target: self, action: #selector(savedRidesPressed))
    }
    @objc func savedRidesPressed() {
        let savedWorkoutVC = SavedWorkoutsViewController()
        navigationController?.pushViewController(savedWorkoutVC, animated: true)
    }
    
    
}
