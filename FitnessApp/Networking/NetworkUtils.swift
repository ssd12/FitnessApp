//
//  Networking.swift
//  BikeRideApp
//
//  Copyright © 2019 Simran Dhillon. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import RxSwift
import CoreData

class NetworkUtils {
    
    let userLoggedIn: BehaviorSubject<Bool> = BehaviorSubject(value: false)
    let logUserOut: BehaviorSubject<Bool> = BehaviorSubject(value: false)
    let userRegistrationStatus: BehaviorSubject<String> = BehaviorSubject(value: "")
    let userActivitiesLoaded: BehaviorSubject<Bool> = BehaviorSubject(value: false)
    let userAccountDeletionStatus: BehaviorSubject<String> = BehaviorSubject(value: "")
    
    enum messageType {
        case userLogin
        case userLogout
        case changeUserPassword
        case addNewActivity
        case removeUserActivity
        case createNewUser
        case deleteUser
        case getUserActivities
    }
    
    let baseURL = "http://127.0.0.1:5000"
    
    init(){
        print("Created Networking class")
    }
    
    func sendRequest(_ parameters: [String: String], _ message: messageType ) {
        print("Sending Request with parameters: \(parameters)")
        switch message{
        case .userLogin:
            AF.request(baseURL+"/login", method: .post, parameters:  parameters, encoding: JSONEncoding.default).responseJSON {
                response in
                let responseBody = String(data:response.data!, encoding: .utf8)
                print("response body: \(String(describing: responseBody)) type: \(type(of: responseBody))")
                self.setUserLoginState(Utilities.userLoginState(rawValue: responseBody ?? "")!, parameters["username"]!)
            }
        case .userLogout:
            AF.request(baseURL+"/logout", method: .post, parameters: parameters, encoding: JSONEncoding.default)
        case .changeUserPassword:
            AF.request(baseURL+"/changeUserPassword", method: .patch, parameters: parameters, encoding: JSONEncoding.default)
        case .addNewActivity:
            AF.request(baseURL+"/addUserActivity", method: .put, parameters: parameters, encoding: JSONEncoding.default)
        case .removeUserActivity:
            AF.request(baseURL+"/removeUserActivity", method: .delete, parameters: parameters, encoding: JSONEncoding.default)
        case .createNewUser:
            AF.request(baseURL+"/createNewUser", method: .put, parameters: parameters, encoding: JSONEncoding.default).validate().responseJSON { response in
                let responseBody = String(data:response.data!, encoding: .utf8)
                print("User delection response body: \(responseBody)")
                self.userAccountDeletionStatus.onNext(responseBody ?? "error")
            }
        case .deleteUser:
            AF.request(baseURL+"/deleteUser", method: .delete, parameters: parameters, encoding: JSONEncoding.default).responseJSON {
                response in switch response.result {
                case .success(let value):
                    print("do something")
                    guard let deletionStatus = value as? String else { return }
                    print("Response to user deletion request: \(deletionStatus)")
                    self.userAccountDeletionStatus.onNext(deletionStatus)
                case .failure(let error):
                    print(error)
                }
            }
        case .getUserActivities:
            AF.request(baseURL+"/"+parameters["username"]!, method: .get, parameters: parameters, encoding: JSONEncoding.default).responseJSON {
                response in
                switch response.result {
                case .success(let value):
                    let responseValue = value as? [String:AnyObject]
                    guard let allActivities = responseValue!["allActivities"] as? [Dictionary<String,String>] else { return }
                    print("allActivities: \(allActivities) type: \(type(of: allActivities))")
                    self.saveUserActivities(allActivities)
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    private func setUserLoginState(_ loginStatus: Utilities.userLoginState, _ username: String) {
        switch loginStatus {
        case .loggedIn:
            print("User logged in")
            setUserDefaults(username, true)
            //setCredentials(username, password)
            userLoggedIn.onNext(true)
            print("emitting login status")
        case .loginError:
            print("Incorrect password and/or username")
            userLoggedIn.onNext(false)
            print("emitting login status")
        case .loggedOut:
            print("user logged out")
            setUserDefaults("", false)
            logUserOut.onNext(true)
            print("emitting login status")
        }
    }
    
    private func setUserRegistrationStatus(_ invalidCredentials: Array<String>) {
        print("Setting user registration status")
        print("All invalid credentials: \(invalidCredentials)")
        if invalidCredentials.isEmpty {
            userRegistrationStatus.onNext("Registration Successful")
        }
        else if invalidCredentials.contains("Username Taken") {
            userRegistrationStatus.onNext("Username Taken. Please use another username")
        }
        else if invalidCredentials.contains("Email Taken") {
            userRegistrationStatus.onNext("Email taken. Please use another email")
        }
        else if invalidCredentials.contains("Invalid Email") {
            userRegistrationStatus.onNext("Invalid email. Please use another email.")
        }
    }
    
    func setUserDefaults(_ username: String, _ loginStatus: Bool) {
        let defaults = UserDefaults.standard
        defaults.set(username, forKey: "username")
        defaults.set(loginStatus, forKey: "isUserLoggedIn")
    }

    private func setCredentials(_ username: String, _ password: String) {
        var credential = UserCredentials(username: username, password: password)
        var userAccount = credential.username
        var password  = credential.password.data(using: String.Encoding.utf8)!
        let server = baseURL
        var query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrAccount as String: userAccount,
                                    kSecAttrServer as String: server,
                                    kSecValueData as String: password]
        //add credentials
        let credentialStatus = SecItemAdd(query as CFDictionary, nil)
        let status = SecItemAdd(query as CFDictionary, nil)
        //guard status == errSecSuccess else { throw KeychainError.error(status: status) }
    }
    
    private func saveUserActivities(_ allActivities: [Dictionary<String,String>]) {
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
                do {
                    try context.save()
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
                print("Added activity with id: \(activity["activityID"])")
            }
        }
        print("All activities loaded")
        userActivitiesLoaded.onNext(true)
        print("Emitted true for userActivitesLoaded behavior subject")
    }
    
}
