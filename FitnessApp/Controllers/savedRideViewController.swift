//
//  savedRideViewController.swift
//  BikeRideApp
//
//  Created by Simran Dhillon on 8/7/18.
//  Copyright © 2018 Simran Dhillon. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class SavedRidesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {
    
    //cell identifier: singleRideCell
    var currentRide: SingleDistanceRide = SingleDistanceRide()
    var dataSource: [NSManagedObject] = []
    
    
    @IBOutlet weak var savedRidesTable: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        savedRidesTable.register(UITableViewCell.self, forCellReuseIdentifier: "singleRideCell")
        //self.dataSource = currentRide.savedRides
        self.getDataSource()
        print(" Number of Rides in dataSource: \(String(dataSource.count))")
        savedRidesTable.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getDataSource(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let context = appDelegate.persistentContainer.viewContext
        let getData = NSFetchRequest<NSManagedObject>(entityName: "SingleRide")
        
        do {
            self.dataSource = try context.fetch(getData)
        } catch let error as NSError {
            print(" Couldn't get data")
        }
    }
    
    //table view functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(" saved rides count inside tableView func: \(String(self.dataSource.count))")
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print(" saved rides count inside tableViewCell func: \(String(self.dataSource.count))")
        let cell = tableView.dequeueReusableCell(withIdentifier: "singleRideCell", for: indexPath)
        let ride = self.dataSource[indexPath.row]
        cell.textLabel?.text = ride.value(forKeyPath: "rideInfo") as? String
        print("Time Stamp value: \(ride.value(forKeyPath: "timeStamp") as? String)")
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            let ride = self.dataSource[indexPath.row]
            let ts = ride.value(forKeyPath: "timeStamp") as? String
            deleteRide(ts!)
            //remove from data source / db
            dataSource.remove(at: indexPath.row)
            //remove from tableView
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Delete"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // your code
        print("row selected")
        let ride = self.dataSource[indexPath.row]
        var text = ride.value(forKeyPath: "rideInfo") as? String
        var distance = ride.value(forKeyPath: "distance") as? String
        var time = ride.value(forKeyPath: "time") as? String
        var speed = ride.value(forKeyPath: "speed") as? String
        //self.dispRideInfo(text ?? "")
        self.dispRideDetails(distance ?? "", time ?? "", speed ?? "")
    }
    
    
    //Entity Name: SingleRide
    //attribute: rideInfo, timeStamp
    
    //delete data from CoreData
    //ts is the time stamp of the ride to be deleted
    func deleteRide(_ ts: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SingleRide")
        fetchRequest.predicate = NSPredicate(format:"timeStamp=%@", ts)
        
        do {
            let test = try managedContext.fetch(fetchRequest)
            let objectToDelete = test[0] as! NSManagedObject
            managedContext.delete(objectToDelete)
            
            do {
                try managedContext.save()
            } catch {
                print(error)
            }
            
        } catch {
            print(error)
        }
    }
    
    //displays a ride alert box
    func dispRideInfo(_ rideInfo: String) {
        let rideInfoAlert = UIAlertController(title: "RideInfo", message: rideInfo, preferredStyle: .alert)
        rideInfoAlert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
        self.present(rideInfoAlert, animated: true)
    }
 
    func dispRideDetails(_ distance: String, _ time: String, _ speed: String) {
        var info = distance + " m\n" + time + " sec\n" +  speed + " m/s"
        let rideAlert = UIAlertController(title: "Ride Details", message: info, preferredStyle: .alert)
        rideAlert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
        self.present(rideAlert, animated: true)
    }
    
}
