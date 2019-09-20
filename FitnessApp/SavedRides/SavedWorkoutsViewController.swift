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
    private var dataSource: [Activity] = []
    
    @IBOutlet weak var savedActivitiesTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        savedActivitiesTable.dataSource = self
        savedActivitiesTable.delegate = self
        savedActivitiesTable.register(UITableViewCell.self, forCellReuseIdentifier: "tableViewCell")
        setupNavBar()
        setSubscriptions()
        print("Finished saved workouts VC setup")
    }
 
    private func setupNavBar() {
        navigationController?.visibleViewController?.navigationItem.title = "Saved Activities"
    }
    
    private func setSubscriptions() {
        let activitiesReadySubscriptions = savedRidesVM.activitiesReadyForDataSource.subscribe(
            onNext: { (ready: Bool) -> Void in if (ready) {self.loadActivities()} },
            onError: { (error: Error) -> Void in print(error)},
            onCompleted: {},
            onDisposed: { self.savedRidesVM.activitiesReadyForDataSource.dispose()})
    }
    
    private func loadActivities() {
        dataSource = savedRidesVM.activities
        savedActivitiesTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = savedActivitiesTable.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath)
        cell.textLabel?.text = self.dataSource[indexPath.row].getDescription()
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            let activityID = self.dataSource[indexPath.row].activityID
            dataSource.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            savedRidesVM.deleteActivity(activityID)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String {
        return "Delete"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let rideAlert = UIAlertController(title: "Ride Details", message: self.dataSource[indexPath.row].dispInfo(), preferredStyle: .alert)
        rideAlert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
        self.present(rideAlert, animated: true)
    }
}
