//
//  SavedWorkoutsViewController.swift
//  BikeRideApp
//
//  Created by Simran Dhillon on 7/13/19.
//  Copyright © 2019 Simran Dhillon. All rights reserved.
//

import Foundation
import UIKit
import CoreData

final class SavedWorkoutsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    
    
    private let savedRidesVM = SavedWorkoutsViewModel()
    private var dataSource: [NSManagedObject] = []
    
    @IBOutlet weak var savedActivitiesTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Created saved workouts view controller")
        savedActivitiesTable.dataSource = self
        savedActivitiesTable.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(loaddataSources), name: .activitiesLoaded, object: nil)
        savedActivitiesTable.register(UITableViewCell.self, forCellReuseIdentifier: "tableViewCell")
        setupNavBar()
        print("Finished saved workouts VC setup")
        savedRidesVM.getAllUserActivities()
    }
 
    private func setupNavBar() {
        navigationController?.visibleViewController?.navigationItem.title = "Saved Activities"
    }
    
    @objc func loaddataSources(_ notification: Notification) {
        if let data = notification.userInfo as? [String: [AnyObject]]
        {
            guard let allUserActivities = data["activities"] else { print("Error getting notification user info"); return }
            print("allUserActivities size: \(allUserActivities.count)")
        }
        print("loading dataSources")
        self.dataSource = savedRidesVM.savedActivities
        savedActivitiesTable.reloadData()
        print("Size fo data source: \(dataSource.count)")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = savedActivitiesTable.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath)
        let activity = self.dataSource[indexPath.row]
        let cellString = activity.value(forKeyPath: "time") as? String ?? " "  + (activity.value(forKey: "activityType") as? String ?? "Unknown activity type")
        cell.textLabel?.text = cellString
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            let activity = self.dataSource[indexPath.row]
            let id = activity.value(forKeyPath: "activityID") as? String
            //remove from data source / db
            dataSource.remove(at: indexPath.row)
            //remove from tableView
            tableView.deleteRows(at: [indexPath], with: .fade)
            //send request to flask to delete on mongo as well
            savedRidesVM.deleteActivity(id!)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String {
        return "Delete"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // your code
        print("row selected")
        let activity = self.dataSource[indexPath.row]
        guard let activityInfo = (activity.value(forKeyPath: "rideDescription") as? String) else { return }
        guard let distance = activity.value(forKeyPath: "distance") as? String else { return }
        self.dispActivityDetails(activityInfo, distance)
    }
    
    func dispActivityDetails(_ description: String, _ distance: String){
        var infoToDisplay = distance + " miles \n" + description
        let rideAlert = UIAlertController(title: "Ride Details", message: infoToDisplay, preferredStyle: .alert)
        rideAlert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
        self.present(rideAlert, animated: true)
    }
}
