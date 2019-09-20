//

import Foundation
import RxSwift
import CoreData

class ActivityDatabase {
 
    static let shared = ActivityDatabase()
    var dataReadyToFetch: BehaviorSubject<Bool> = BehaviorSubject(value: false)
    private var allActivitiesArray: [Activity] = [Activity]()
    private var allActivities: [Dictionary<String, String>] = [Dictionary<String, String>]()
    private let appDelegate = UIApplication.shared.delegate
    private var context: NSManagedObjectContext
    
    init() {
        context = (appDelegate as? AppDelegate)!.persistentContainer.viewContext
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
        clearDB()
        addActivitiesToDB()
    }
    
    //clear core data db
    private func clearDB() {
        let getCurrentActivitiesRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FitnessActivity")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: getCurrentActivitiesRequest)
        do {
            try context.execute(deleteRequest)
            try context.save()
            // check to make sure it's cleared
            let activities = try context.fetch(getCurrentActivitiesRequest)
            guard let allNSManangedObject = try activities as? [NSManagedObject] else  { print("error getting nsmanaged object result"); return}
            print("No. of NSManagedObjects: \(allNSManangedObject.count)")
            allActivitiesArray.removeAll()
            print("All activities array count: \(allActivitiesArray.count)")
            print("Core Data db cleared")
        } catch {
            print("error clearing db")
        }
    }
    
    private func addActivitiesToDB() {
        print("Adding activities to Core Data")
        let entity = NSEntityDescription.entity(forEntityName: "FitnessActivity", in: context)!
        let getCurrentActivitiesRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FitnessActivity")
        var allActivityIDs = [String]()
        do {
            let result  = try context.fetch(getCurrentActivitiesRequest)
            for data in result as! [NSManagedObject] {
                allActivityIDs.append(data.value(forKey: "activityID") as? String ?? "")
            }
            print("[NSManangedObject] count: \(result.count)")
        } catch {
            print("Fetch request failed")
        }
        print("Current activity IDs present: \(allActivityIDs)")
        for activity in allActivities {
            if (allActivityIDs.contains(activity["activityID"]!)) {
                //do nothing
                print("activity already exists")
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
        print("allActivitiesArray count: \(allActivitiesArray.count)")
        dataReadyToFetch.onNext(true)
    }
    
    
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
        NetworkManager.shared.sendRequest(parameters, .removeUserActivity)
        print("Sent request to delete activity with id: \(id)")
    }
    
    func fetchActivities() -> [Activity] {
        print("Num. of activities: \(allActivitiesArray.count)")
        return allActivitiesArray
    }
}
