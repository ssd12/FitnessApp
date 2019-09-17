import Foundation
import UIKit

class UserSettingsPageViewController: UIViewController {
    
    @IBOutlet weak var deleteUserAccountButton: UIButton!
    
    override func viewDidLoad() {
        self.navigationController?.visibleViewController?.navigationItem.title = "User Settings"
        let deletionStatusSubscription = ObserverService.shared.userAccountDeletedSuccesful.subscribe(
            onNext: { (status: Bool) -> Void in if (status) { self.handleDeletionStatus()} },
            onError: { (error: Error) -> Void in print(error)},
            onCompleted: {},
            onDisposed: {ObserverService.shared.disposeBag.insert(ObserverService.shared.userAccountDeletedSuccesful)})
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
        NetworkManager.shared.sendRequest(parameters, .deleteUser)
    }
    
    private func handleDeletionStatus() {
        User.profile.clearUserDefaults()
        let loginVC = LoginScreenViewController()
        self.navigationController?.popToViewController(loginVC, animated: true)
    }
}
