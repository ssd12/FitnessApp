//
//  workoutRideViewController.swift
//  BikeRideApp
//
//  Created by Simran Dhillon on 8/7/18.
//  Copyright © 2018 Simran Dhillon. All rights reserved.
//

//viewController for the workout ride

import Foundation

import UIKit

class WorkoutRideViewController: UIViewController {
    
    //update is called when the WorkoutRide model's state changes
    @objc func update() {
        print(" Getting Notifications from model")
        //update views (first workout properties then current workout state)
        numberOfSetsLabel.text = String(currentWorkout.numberOfSets)
        restLabel.text = String(currentWorkout.elapsedRestUnits)
        workoutLabel.text = String(currentWorkout.elapsedSprintUnits)
        currentSetLabel.text = String(currentWorkout.currentSet)
    }
    
    var currentWorkout: WorkoutRide = WorkoutRide()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setStepper.minimumValue=1
        //Add controller as an observer for different notifications from model
        NotificationCenter.default.addObserver(self, selector: #selector(update), name: .workoutPropertiesUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(update), name: .sprintUnitUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(update), name: .restUnitUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(update), name: .currentSetUpdated, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    //workoutRide buttons
    @IBOutlet weak var sprintButton: UIButton!
    @IBOutlet weak var restButton: UIButton!
    @IBOutlet weak var setButton: UIButton!
    @IBOutlet weak var startWorkoutButton: UIButton!
    @IBOutlet weak var stopWorkoutButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    //labels for workout
    @IBOutlet weak var sprintUnitLabel: UILabel!
    @IBOutlet weak var restUnitLabel: UILabel!
    @IBOutlet weak var numberOfSetsLabel: UILabel!
    @IBOutlet weak var workoutLabel: UILabel!
    @IBOutlet weak var restLabel: UILabel!
    @IBOutlet weak var currentSetLabel: UILabel!
    
    //workoutRide editBoxes
    @IBOutlet weak var sprintEditBox: UITextField!
    @IBOutlet weak var restEditBox: UITextField!
    
    //UISegmentedControl
    @IBOutlet weak var splitTypeControl: UISegmentedControl!
    
    //stepper to change set values
    @IBOutlet weak var setStepper: UIStepper!
    
    //split type is changed
    //change units and let the model know
    @IBAction func splitTypeChanged(_ sender: UISegmentedControl) {
        let splitSelection = sender.titleForSegment(at: sender.selectedSegmentIndex)!.description
        print(splitSelection)
        currentWorkout.workoutType = splitSelection
    }
    
    //set the sprint val
    @IBAction func sprintSplitSet(_ sender: UIButton) {
        //get value from editBox and set the sprint value
        let sprintSplitVal = sprintEditBox!.text ?? "0"
        print("Sprint value: \(sprintSplitVal)")
        currentWorkout.sprintUnit = Double(sprintSplitVal)!
    }
    
    //set the rest value
    @IBAction func restSplitSet(_ sender: UIButton) {
        let restSplitVal = restEditBox!.text ?? "0"
        print("Rest value: \(restSplitVal)")
        currentWorkout.restUnit = Double(restSplitVal)!
    }
    
    //get set value from
    @IBAction func setButtonPressed(_ sender: UIButton) {
        let numOfSetsVal = self.setStepper.value
        print(" Setting num of sets to: \(String(numOfSetsVal))")
        currentWorkout.setNumberOfSets(Int(numOfSetsVal))
    }
    
    @IBAction func setStepperValueChange(_ sender: UIStepper) {
        numberOfSetsLabel.text = String(sender.value)
    }
    
    @IBAction func startButtonPressed(_ sender: UIButton) {
        currentWorkout.startRide()
    }
    
    @IBAction func stopButtonPressed(_ sender: UIButton) {
        currentWorkout.stopRide()
    }
    
}
