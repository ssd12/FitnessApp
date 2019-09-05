//
//  UserSettingsPageViewController.swift
//  FitnessApp
//
//  Created by Simran Dhillon on 8/22/19.
//  Copyright © 2019 Simran Dhillon. All rights reserved.
//

import Foundation
import UIKit

class UserSettingsPageViewController: UIViewController {
    
    let networkUtils = NetworkUtils()
    
    @IBOutlet weak var deleteUserAccountButton: UIButton!
    
    override func viewDidLoad() {
        setupNavBar()
        //let deletionStatusSubscription = networkUtils.userAccountDeletionStatus.subscribe(onNext: handleDeletionStatus(_:), onError: handleDeletionError(_:), onCompleted: {}, onDisposed: {})
    }
    
    private func setupNavBar() {
        self.navigationController?.visibleViewController?.navigationItem.title = "User Settings"
    }
    
    @IBAction func deleteUserAccountButtonPressed(_ sender: Any) {
            showUserAccountDeletionAlert()
    }
    
    func showUserAccountDeletionAlert() {
        let accountDeletionAlert = UIAlertController(title: "Account Deletion", message: "Are you sure you want to delete your acount?", preferredStyle: .alert)
        accountDeletionAlert.addAction( UIAlertAction(title: "Yes", style: .default, handler: { _ in self.sendDeletionRequest()} ))
        self.present(accountDeletionAlert, animated: true)
        accountDeletionAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
    }
    
    private func sendDeletionRequest() {
        print("Sending request to delete user account")
        let parameters = ["username":UserDefaults.standard.object(forKey: "username") as? String ?? ""]
        networkUtils.sendRequest(parameters, .deleteUser)
        networkUtils.setUserDefaults("", false)
        let loginVC = LoginScreenViewController()
        self.navigationController?.popToViewController(loginVC, animated: true)
    }
    
    private func handleDeletionStatus(_ status: String) {
        print("Deletion Account status: \(status)")
        if (status == "deleted"){
            //"log" user out and transition to login page
            //networkUtils.setUserDefaults("", false)
            //self.navigationController?.popViewController(animated: true)
            
        } else {
            //display a alert box stating there is an error
        }
    }
    
    private func handleDeletionError(_ error: Error) {
        print("Error during account deletion")
    }
    
}
