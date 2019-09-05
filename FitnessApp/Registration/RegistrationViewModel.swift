//
//  RegistrationViewModel.swift
//  BikeRideApp
//
//  Created by Simran Dhillon on 8/8/19.
//  Copyright © 2019 Simran Dhillon. All rights reserved.
//

import Foundation
import RxSwift

final class RegistrationViewModel {
    
    var userRegistrationStatus: String = "Registration Status"
    var networkUtilities: NetworkUtils = NetworkUtils()
    var disposeBag = DisposeBag()
    
    init() {
        NotificationCenter.default.post(name: .registrationStatusUpdate, object: nil)
        setSubscription()
    }
    
    func registerUser(_ username: String, _ password: String, _ email: String, _ securityQuestion: String, _ securityQuestionAnswer: String) {
        print("Sending request to register user")
        let parameters = ["username": username, "password":password, "email":email, "securityQuestion":securityQuestion, "securityQuestionAnswer":securityQuestionAnswer]
        print("paramters: \(parameters)")
        networkUtilities.sendRequest(parameters, .createNewUser)
    }
    
    func emailValidCheck(_ email: String) -> Bool {
        return true
    }
    
    private func setSubscription() {
        let registrationStatusSubscription = networkUtilities.userRegistrationStatus.asObserver().subscribe(onNext: handleRegistrationStatus(_:), onError: handleError(_:), onCompleted: { }, onDisposed: handleOnDispose)
    }
    
    private func handleRegistrationStatus(_ status: String) {
        print("Handling user registration status: \(status)")
        userRegistrationStatus = status
        NotificationCenter.default.post(name: .registrationStatusUpdate, object: nil)
    }
    
    private func handleError(_ error: Error) {
        userRegistrationStatus = "Error during registration"
        NotificationCenter.default.post(name: .registrationStatusUpdate, object: nil)
    }
    
    private func handleOnDispose() {
        networkUtilities.userRegistrationStatus.dispose()
    }
}

extension Notification.Name {
    static let registrationStatusUpdate = Notification.Name("registrationStatusUpdate")
}
