import Foundation
import CoreData
import UIKit
import RxSwift

class SavedActivitiesViewModel {
    
    private(set) var activities: [ActivityModel] = [ActivityModel]()
    var activitiesReadyForDataSource: BehaviorSubject<Bool> = BehaviorSubject(value: false)
    
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
    
    private func getActivityArray() {
        print("Getting activity array")
        activities = ActivityDatabase.shared.fetchActivities()
        activitiesReadyForDataSource.onNext(true)
    }
    
    func deleteActivity(_ id: String) {
        ActivityDatabase.shared.deleteActivity(id)
    }
}
