//

import Foundation
import RxSwift
import CoreData

class ActivityDatabase {
 
    static let shared = ActivityDatabase()
    var dataReadyToFetch: BehaviorSubject<Bool> = BehaviorSubject(value: false)
    private var allActivitiesArray: [Activity] = [Activity]()
    private var allActivities: [Dictionary<String, String>] = [Dictionary<String, String>]()
    
    init() {
        setSubscriptions()
    }
    
    func getActivities() {
        let parameters = ["username":UserDefaults.standard.object(forKey: "username") as? String ?? ""]
        print("Getting user activities with username: \(parameters["username"]!)")
        NetworkManager.shared.sendRequest(parameters, .getUserActivities)
    }
    
    private func setSubscriptions() {
        let allActivityDataSubscription = ObserverService.shared.allActivityDataFetched.subscribe(
            onNext: { (isFetched: Bool) -> Void in self.loadIntoCoreData()},
            onError: { (error: Error) -> Void in print(error)},
            onCompleted: {},
            onDisposed: {ObserverService.shared.allActivityDataFetched.dispose()})
        print("Finished setting subscriptions for Activity Database")
    }
 
    func setActivityDictionary(_ dict: [Dictionary<String, String>]) {
        allActivities = dict
    }
    
    private func loadIntoCoreData() {
        print("all activities dictionary: \(allActivities)")
        print("Saving user activity information in Core Data")
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "FitnessActivity", in: context)!
        let getCurrentActivitiesRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FitnessActivity")
        var allActivityIDs = [String]()
        do {
            let result  = try context.fetch(getCurrentActivitiesRequest)
            for data in result as! [NSManagedObject] {
                allActivityIDs.append(data.value(forKey: "activityID") as? String ?? "")
            }
        } catch {
            print("Fetch request failed")
        }
        print("Current activity IDs present: \(allActivityIDs)")
        for activity in allActivities {
            if (allActivityIDs.contains(activity["activityID"]!)) {
                print("Activity already exists")
            } else {
                print("Adding new activity")
                let fitnessActivity = NSManagedObject(entity: entity, insertInto: context)
                fitnessActivity.setValue(activity["activityID"],forKeyPath: "activityID")
                fitnessActivity.setValue(activity["activityType"],forKeyPath: "activityType")
                fitnessActivity.setValue(activity["distance"],forKeyPath: "distance")
                fitnessActivity.setValue(activity["time"],forKeyPath: "time")
                let basicRideDescription = activity["activityType"] ?? "unknown activity" + " on: " + (activity["activityID"] ?? "unknown date")
                fitnessActivity.setValue(basicRideDescription, forKeyPath: "rideDescription")
                let newActivity = Activity(activityID: activity["activityID"]!, activityType: activity["activityType"]!, distance: activity["distance"]!, time: activity["time"]!)
                allActivitiesArray.append(newActivity)
                do {
                    try context.save()
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
                print("Added activity with id: \(activity["activityID"])")
            }
        }
        print("All activities loaded")
        dataReadyToFetch.onNext(true)
    }
    
    func deleteActivity(_ id: String) {
        
    }
    
    func fetchActivities() -> [Activity] {
        print("Num. of activities: \(allActivitiesArray.count)")
        return allActivitiesArray
    }
}
