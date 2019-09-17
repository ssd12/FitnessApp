import Foundation
import UIKit

final class RegistrationViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet private weak var usernameTextBox: UITextField!
    @IBOutlet private weak var passwordTextBox: UITextField!
    @IBOutlet private weak var emailTextBox: UITextField!
    @IBOutlet private weak var securityQuestionPicker: UIPickerView!
    @IBOutlet private weak var securityAnswerTextBox: UITextField!
    @IBOutlet private weak var registrationStatusLabel: UILabel!
    @IBOutlet private weak var registrationSubmitButton: UIButton!
    
    private var registrationViewModel = RegistrationViewModel()
    private var pickerSecurityQuestions = ["Name of Pet","City of Birth","Favorite Band"]
    private var pickerQuestion = "Name of pet"
    
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self, selector: #selector(userSuccessfullyRegistered), name: .registrationSuccess, object: nil)
        setupViews()
    }
    
    private func setupViews() {
        self.securityQuestionPicker.dataSource = self
        self.securityQuestionPicker.delegate = self
        passwordTextBox.isSecureTextEntry = true
        print("Setup views for registration page")
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        view.addGestureRecognizer(tap)
        registrationViewModel.rx.base.userRegistrationStatusDescription.bind(to: registrationStatusLabel.rx.text).disposed(by: registrationViewModel.disposeBag)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1   }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        pickerQuestion = pickerSecurityQuestions[row]
        return pickerQuestion
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerSecurityQuestions.count
    }
    
    @IBAction func registrationButtonPressed(_ sender: Any) {
        guard let newUserName = usernameTextBox.text, userInputValid(newUserName) else {
            displayInvalidUserInputAlertBox("Username")
            return
        }
        guard let newUserPassword = passwordTextBox.text, userInputValid(newUserPassword) else {
            displayInvalidUserInputAlertBox("Password")
            return
        }
        guard let newUserSecurityQuestionAnswer = securityAnswerTextBox.text, userInputValid(newUserSecurityQuestionAnswer) else {
            displayInvalidUserInputAlertBox("User Security Question Answer")
            return
        }
        guard let userEmail = emailTextBox.text, userInputValid(userEmail) else {
            let invalidEmailAlert = UIAlertController(title: "Registration Error", message: "Invalid Email", preferredStyle: .alert)
            invalidEmailAlert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
            return
        }
        registrationViewModel.registerUser(newUserName, newUserPassword, userEmail, pickerQuestion, newUserSecurityQuestionAnswer)
    }
    
    private func userInputValid(_ input: String?) -> Bool {
        return (input?.count ?? 0 > 3)
    }
    
    private func displayInvalidUserInputAlertBox(_ invalidUserField: String) {
        let invalidUserInputAlert = UIAlertController(title: "Registration error", message: "\(invalidUserField) must be at least 4 characters or longer", preferredStyle: .alert)
        invalidUserInputAlert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
        self.present(invalidUserInputAlert, animated: true)
    }
    
    @objc func userSuccessfullyRegistered() {
        let activitySelectionVC = ActivitySelectionViewController()
        self.navigationController?.popToViewController(activitySelectionVC, animated: true)
    }
}
