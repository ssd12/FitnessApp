import Foundation
import Alamofire

struct Request {
    
    let parameters: [String:String]
    let requestType: RequestType
    let baseURL = "http://34.212.22.226:5000"
    
    func sendRequest() {
        switch requestType {
        case .userLogin:
            print("Request: user login.")
            AF.request(baseURL+"/login", method: .post, parameters:  parameters, encoding: JSONEncoding.default).responseJSON { response in self.handleResponse(response.result) }
        case .userLogout:
            print("Request: user logout.")
            AF.request(baseURL+"/logout", method: .post, parameters:  parameters, encoding: JSONEncoding.default).responseJSON { response in self.handleResponse(response.result) }
        case .addNewActivity:
            print("Request: add new activity")
            AF.request(baseURL+"/addUserActivity", method: .put, parameters:  parameters, encoding: JSONEncoding.default).responseJSON { response in self.handleResponse(response.result) }
        case .removeUserActivity:
            print("Request: remove user activity")
            AF.request(baseURL+"/removeUserActivity", method: .delete, parameters:  parameters, encoding: JSONEncoding.default).responseJSON { response in self.handleResponse(response.result) }
        case .createNewUser:
            print("Request: create new user")
            AF.request(baseURL+"/createNewUser", method: .put, parameters:  parameters, encoding: JSONEncoding.default).responseJSON { response in self.handleResponse(response.result) }
        case .deleteUser:
            print("Request: delete user")
            AF.request(baseURL+"/deleteUser", method: .delete, parameters:  parameters, encoding: JSONEncoding.default).responseJSON { response in self.handleResponse(response.result) }
        case .getUserActivities:
            print("Request: get all user activities")
            AF.request(baseURL+"/getUserActivities", method: .post, parameters:  parameters, encoding: JSONEncoding.default).responseJSON { response in self.handleResponse(response.result) }
        }
    }
    
    func handleResponse(_ response: Result<Any, AFError>) {
        switch response {
        case .success(let responseValue):
            print("Handling response from server")
            print("Response Value: \(responseValue)")
            //guard let response = responseValue as? [String:String] else {
            //    print("getting different format")
            //    print("responseValue type: \(type(of: responseValue))")
            //    let response = responseValue as? [String:AnyObject];
            //   _ = Parser(responseValue as AnyObject)
            //    }
            guard let response = responseValue as? [String:AnyObject] else { return }
            print("response: \(response)")
            _ = Parser(responseValue as AnyObject)
        case .failure(let responseError):
            print("Handling error from server")
            print("Response error: \(responseError)")
            print("Error occured")
        }
    }
    
}

enum RequestType: String {
    case userLogin = "userLogin"
    case userLogout = "userLogout"
    case addNewActivity = "addNewActvitiy"
    case removeUserActivity = "removeUserActivity"
    case createNewUser = "createNewUser"
    case deleteUser = "deleteUser"
    case getUserActivities = "getUserActivities"
}
