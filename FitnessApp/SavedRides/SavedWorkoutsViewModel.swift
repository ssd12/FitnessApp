//
//  SavedRidesViewModel.swift
import Foundation
import CoreData
import UIKit

class SavedWorkoutsViewModel {
    
    private(set) var savedActivities: [NSManagedObject] = []
    
    init() {
        setSubscriptions()
        ActivityDatabase.shared.getActivities()
    }
    
    private func setSubscriptions() {
        let dataReadyToFetchSubscription = ActivityDatabase.shared.dataReadyToFetch.subscribe(
            onNext: { (isReady: Bool) -> Void in if (isReady) { self.getActivityArray()} },
            onError: { (error: Error) -> Void in print(error) },
            onCompleted: {},
            onDisposed: {ActivityDatabase.shared.dataReadyToFetch.dispose()})
    }
    
    //Get activity arrray from DB
    private func getActivityArray() {
        print("Getting activity array")
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
        print("Deleted activity with id: \(id)")
    }
    
}

extension Notification.Name {
    static let activitiesLoaded = Notification.Name("activitiesLoaded")
}
