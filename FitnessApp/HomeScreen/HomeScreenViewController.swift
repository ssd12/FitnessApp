//
//  HomeScreenViewController.swift
//  BikeRideApp
//
//  Created by Simran Dhillon on 6/26/19.
//  Copyright © 2019 Simran Dhillon. All rights reserved.
//

import Foundation
import UIKit

final class HomeScreenViewController: UIViewController, UINavigationControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func FreeRideButtonPressed(_ sender: Any) {
        let freeRideVC = FreeRideViewController()
        self.navigationController?.pushViewController(freeRideVC, animated: true)
    }
    
    @IBAction func IntervalRideButtonPressed(_ sender: Any) {
        let intervalRideVC = IntervalRideViewController()
        self.navigationController?.pushViewController(intervalRideVC, animated: true)
    }
}
