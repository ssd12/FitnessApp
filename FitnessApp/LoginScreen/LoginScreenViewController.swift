//
//  LoginScreenViewController.swift
//  BikeRideApp
//
//  Created by Simran Dhillon on 8/3/19.
//  Copyright © 2019 Simran Dhillon. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

final class LoginScreenViewController: UIViewController{
    
    private var loginViewModel = LoginScreenViewModel()
    @IBOutlet private weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginStatusLabel: UILabel!
    
    
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateUserLoginStatus), name: .registrationStatusUpdate, object: nil)
        setupViews()
    }
    
    
    @IBAction func userSignInButton(_ sender: Any) {
        let username = loginTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        loginViewModel.login(username, password)
    }
    
    private func setupViews() {
        passwordTextField.isSecureTextEntry = true
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        view.addGestureRecognizer(tap)
        clearUserEntryFields()
        setupNavBar()
    }
    
    private func setupNavBar() {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    @IBAction func userRegistrationButton(_ sender: Any) {
        print("Transitioning to registration page")
        let registrationVC = RegistrationViewController()
        self.navigationController?.pushViewController(registrationVC, animated: true)
    }
    
    @objc func updateUserLoginStatus() {
        loginStatusLabel.text = loginViewModel.userLoginInfo
        if (loginViewModel.isUserLoggedIn){
            let activitySelectionVC = ActivitySelectionViewController()
            self.navigationController?.pushViewController(activitySelectionVC, animated: true)
            clearUserEntryFields()
        }
    }
    
    private func clearUserEntryFields() {
        loginTextField.text = "Enter username"
        passwordTextField.text = "password"
    }
}
