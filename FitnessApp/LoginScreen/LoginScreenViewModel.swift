//
//  LoginScreenViewModel.swift
//  BikeRideApp
//
//  Copyright © 2019 Simran Dhillon. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


class LoginScreenViewModel {
    
    let networkUtilities = NetworkUtils()
    var userLoginInfo = ""
    var isUserLoggedIn: Bool = false
    
    init() {
        setSubscription()
    }
    
    private func handleUserLogIn(_ loginStatus: Bool) {
        print("LoginScreenViewModel: Handle user login. Logged in: \(loginStatus)")
        if (loginStatus) {
            userLoginInfo = " User Logging in."
            isUserLoggedIn = true
        } else {
            userLoginInfo = " Incorrect password and/or username."
        }
        NotificationCenter.default.post(name: .registrationStatusUpdate, object: nil)
    }
    
    private func handleUserLoginError(_ error: Error) {
        print("LoginScreenViewModel: Handle user login error")
        userLoginInfo = " Error logging user in."
        NotificationCenter.default.post(name: .registrationStatusUpdate, object: nil)
    }
    
    private func handleUserLoginCompletion() {
        print("LoginScreenViewModel: Handle user login completion")
    }
    
    private func handleUserLoginDisposale() {
        networkUtilities.userLoggedIn.dispose()
    }
    
    func login(_ username: String, _ password: String) {
        let parameters = ["username":username, "password":password]
        networkUtilities.sendRequest(parameters, .userLogin)
    }
    
    func setSubscription() {
        let loginStatusSubscription = networkUtilities.userLoggedIn.subscribe(onNext: handleUserLogIn(_:), onError: handleUserLoginError(_:), onCompleted: handleUserLoginCompletion, onDisposed: handleUserLoginDisposale)
    }
}

extension Notification.Name {
    static let loginStatus = Notification.Name("loginStatusUpdate")
}
