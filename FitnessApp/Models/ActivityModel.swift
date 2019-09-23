//
//  Activity.swift
import Foundation

struct ActivityModel {
    
    let activityID: String
    let activityType: String
    let distance: String
    let time: String
    
    func getDescription() -> String {
        let description = activityType + ": " + distance + " m " + time + " sec"
        return description
    }

    func dispInfo() -> String {
        let index = activityID.index(activityID.startIndex, offsetBy: 10)
        let dateOnly = activityID[..<index]
        let info = getDescription() + " \n" + dateOnly
        print("Activity Information: \(info)")
        return info
    }
}
