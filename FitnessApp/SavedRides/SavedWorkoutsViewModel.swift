//
//  SavedRidesViewModel.swift
//  BikeRideApp
//
//  Created by Simran Dhillon on 7/13/19.
//  Copyright © 2019 Simran Dhillon. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class SavedWorkoutsViewModel {
    
    private(set) var savedActivities: [NSManagedObject] = []
    let networkUtils = NetworkUtils()
    
    init() {
        print("SavedWorkoutsViewModel created")
        let userActivityLoadedSubscription = networkUtils.userActivitiesLoaded.subscribe(onNext: handleUserActivitiesLoaded(_:), onError: handleActivityLoadingError(_:), onCompleted: handleOnCompleted, onDisposed: handleOnCompleted)
    }
    
    func getAllUserActivities() {
        let parameters = ["username":UserDefaults.standard.object(forKey: "username") as? String ?? ""]
        print("Getting user activities with username: \(UserDefaults.standard.object(forKey: "username") as? String ?? "")")
        networkUtils.sendRequest(parameters,  .getUserActivities)
        print("Request sent to get all user activities")
    }

    func loadSavedActivities() {
        print("Loading saved activites")
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let context = appDelegate.persistentContainer.viewContext
        let getData = NSFetchRequest<NSManagedObject>(entityName: "FitnessActivity")
        
        do {
            self.savedActivities = try context.fetch(getData)
        } catch let error as NSError {
            print("Couldn't get the data")
        }
        print("Fetched Data")
        print("Number of saved activites: \(savedActivities.count)")
        let activitiesToPost = ["activities":savedActivities]
        NotificationCenter.default.post(name: .activitiesLoaded, object: nil, userInfo: activitiesToPost )
    }
    
    func handleUserActivitiesLoaded(_ status: Bool) {
        if (status) {
            print("User activities loaded status: \(status)")
            loadSavedActivities()
        } else {
            print("Activities not loaded yet")
        }
    }
    
    func handleActivityLoadingError(_ error: Error) {
        print("There was an error loading the acitivites into Core Data")
    }
    
    func handleOnCompleted() {
    }
    
    //deletes from CoreData first, and then sends request to delete on mongo
    func deleteActivity(_ id: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FitnessActivity")
        fetchRequest.predicate = NSPredicate(format:"activityID=%@", id)
        
        do {
            let test = try context.fetch(fetchRequest)
            let objectToDelete = test[0] as! NSManagedObject
            context.delete(objectToDelete)
            
            do {
                try context.save()
            } catch { print(error) }
        } catch { print(error) }
        
        
        let parameters = ["activityID":id, "username":UserDefaults.standard.object(forKey: "username") as? String ?? ""]
        networkUtils.sendRequest(parameters, .removeUserActivity)
        print("Deleted activity with id: \(id)")
    }
    
}

extension Notification.Name {
    static let activitiesLoaded = Notification.Name("activitiesLoaded")
}
