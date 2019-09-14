import Foundation


class NetworkManager {
    
    
    static let shared = NetworkManager()

    
    init(){
        
    }
    
    func sendRequest(_ parameters: [String: String], _ requestType: RequestType) {
        let request = Request(parameters: parameters, requestType: requestType)
        request.sendRequest()
    }
    
    
}
