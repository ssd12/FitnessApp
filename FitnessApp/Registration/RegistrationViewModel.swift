//
//  RegistrationViewModel.swift
//  BikeRideApp
//
//  Created by Simran Dhillon on 8/8/19.
//  Copyright © 2019 Simran Dhillon. All rights reserved.
//

import Foundation
import RxSwift

final class RegistrationViewModel: ReactiveCompatible {
    
    
    let userRegistrationStatusDescription: BehaviorSubject<String> = BehaviorSubject(value: "")
    
    var userRegistrationStatus: String = "Registration Status"
    var networkUtilities: NetworkUtils = NetworkUtils()
    var disposeBag = DisposeBag()
    
    init() {
        setSubscription()
    }
    
    func registerUser(_ username: String, _ password: String, _ email: String, _ securityQuestion: String, _ securityQuestionAnswer: String) {
        print("Sending request to register user")
        let parameters = ["username": username, "password":password, "email":email, "securityQuestion":securityQuestion, "securityQuestionAnswer":securityQuestionAnswer]
        print("paramters: \(parameters)")
        NetworkManager.shared.sendRequest(parameters, .createNewUser)
        User.profile.setUserDefaults(username)
    }
    
    private func setSubscription() {
        let registrationSuccessfulSubscription = ObserverService.shared.registrationSuccessful.subscribe(
            onNext: { (status: Bool) -> Void in if (status) { NotificationCenter.default.post(name: .registrationSuccess, object: nil) } else { User.profile.clearUserDefaults()} },
            onError: { (error: Error) -> Void in print(error)},
            onCompleted: {},
            onDisposed: {ObserverService.shared.disposeBag.insert(ObserverService.shared.registrationSuccessful)})
        
        let registrationStatusDescriptionSubscription = ObserverService.shared.registrationStatusDescription.subscribe(
            onNext: { (description: String) -> Void in self.userRegistrationStatusDescription.onNext(description)},
            onError: { (error: Error) -> Void in print(error)},
            onCompleted: {},
            onDisposed: {ObserverService.shared.disposeBag.insert(ObserverService.shared.registrationStatusDescription)})
    }
}

extension Notification.Name {
    static let registrationSuccess = Notification.Name("registrationSucess")
}
