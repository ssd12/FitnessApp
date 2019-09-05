//
//  ViewController.swift
//  BikeRideApp
//
//  Created by Simran Dhillon on 8/1/18.
//  Copyright © 2018 Simran Dhillon. All rights reserved.
//

import UIKit
import os

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        os_log("Starting main screen.")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //button for single distance rides
    @IBOutlet weak var singleRideButton: UIButton!
    //button for workout rides
    @IBOutlet weak var workoutRideButton: UIButton!
    
    

    
    
  
    

}

