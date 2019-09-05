//
//  ActivitySelectionViewController.swift
//  BikeRideApp
//
//  Created by Simran Dhillon on 8/19/19.
//  Copyright © 2019 Simran Dhillon. All rights reserved.
//

import Foundation
import UIKit

class ActivitySelectionViewController: UIViewController {
    
    let networkUtilities = NetworkUtils()
    
    override func viewDidLoad() {
        setupNavBar()
    }
    
    private func setupNavBar() {
        self.navigationController?.visibleViewController?.navigationItem.title = "Activity Selection"
        self.navigationController?.visibleViewController?.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self,  action: #selector(logoutUser))
        
        self.navigationController?.visibleViewController?.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(accessUserSettings))
        
        let loginStatusSubscription = networkUtilities.logUserOut.subscribe(onNext: handleUserLogOut(_:), onError: handleUserLoginError(_:), onCompleted: handleUserLoginCompletion, onDisposed: handleUserLoginDisposale)
    }
    
    @IBAction func walkButtonpressed(_ sender: Any) {
        let freeRideVC = FreeRideViewController()
        freeRideVC.activityType = "Walk"
        self.navigationController?.pushViewController(freeRideVC, animated: true)
    }
    
    @IBAction func bikeButtonPressed(_ sender: Any) {
        let freeRideVC = FreeRideViewController()
        freeRideVC.activityType = "Bike"
        self.navigationController?.pushViewController(freeRideVC, animated: true)
    }
 
    @IBAction func runButtonPressed(_ sender: Any) {
        let freeRideVC = FreeRideViewController()
        freeRideVC.activityType = "Walk"
        self.navigationController?.pushViewController(freeRideVC, animated: true)
    }
    
    @IBAction func savedActivitesButtonPressed(_ sender: Any) {
        let savedActivitiesVC = SavedWorkoutsViewController()
        self.navigationController?.pushViewController(savedActivitiesVC, animated: true)
    }
    
    
    private func handleUserLogOut(_ logoutStatus: Bool) {
        print("Logout user: \(logoutStatus)")
            if (logoutStatus) {
                self.navigationController?.popViewController(animated: true)
        }
    }
    
    private func handleUserLoginError(_ error: Error) {
        print("Logout Error")
    }
    
    private func handleUserLoginCompletion() {
        print("Handle user login/logout completion")
    }
    
    private func handleUserLoginDisposale() {
        networkUtilities.userLoggedIn.dispose()
    }
    
    @objc func logoutUser() {
        print("Logging user out")
        let parameters = ["username":UserDefaults.standard.object(forKey: "username") as? String ?? ""]
        networkUtilities.sendRequest(parameters, .userLogout)
    }
    
    @objc func accessUserSettings() {
        let userSettingsVC = UserSettingsPageViewController()
        self.navigationController?.pushViewController(userSettingsVC, animated: true)
    }
    
}
