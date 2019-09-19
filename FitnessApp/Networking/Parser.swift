import Foundation
import RxSwift

class Parser {
    init(_ responseToParse: Any) {
        //guard let response = responseToParse as? [String:String] else { return }
        //guard let body = response["body"] else { return }
        //guard let responseType = response["type"] else { return }
        guard let response = responseToParse as? [String:Any] else { print("error"); return}
        guard let responseType = response["type"] as? String else {print("error getting type"); return }
        guard let body = response["body"] as? String else {print("error getting body"); print("body type: \(type(of: response["body"]))"); parseActivitiesDict(response["body"]); return }
        print("Parsed server message. Response type: \(responseType)")
        ObserverService.shared.emitObservable(Utilities.ResponseType(rawValue: responseType) ?? .error, body)
    }
    
    private func parseActivitiesDict(_ activities: Any) {
        print("Parser.parseActivitiesDict : parsing NSDict ")
        let allInfo = activities as? [String:Any]
        guard let allActivitiesUnformatted = allInfo!["allActivities"] else { print("Error getting all activities unformatted"); return}
        guard let allActivities = allActivitiesUnformatted as? [Dictionary<String, String>] else {
                print("Error getting all activities")
                return
        }
        print("The number of activities is: \(allActivities.count)")
        print("All activities type: \(type(of: allActivities))")
        ObserverService.shared.emitObservable(allActivities)
    }
}
