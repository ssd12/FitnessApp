import Foundation
import RxSwift
import RxCocoa

class LoginScreenViewModel: ReactiveCompatible {
    
    let userLoginInfo: BehaviorSubject<String> = BehaviorSubject(value: "User not Logged in.")
    let disposeBag = DisposeBag()
    
    init() {
        let loginStatusSubscription = ObserverService.shared.isUserLoggedIn.subscribe(onNext: handleUserLogIn(_:), onError: handleUserLoginError(_:), onCompleted: {}, onDisposed: { ObserverService.shared.disposeBag.self.insert(ObserverService.shared.isUserLoggedIn)
        })
        
        let loginStatusDescriptionSubscription = ObserverService.shared.userLoginStatusDescription.subscribe(onNext: { (description: String) -> Void in self.userLoginInfo.onNext(description)}, onError: handleUserLoginError(_:), onCompleted: {}, onDisposed: {ObserverService.shared.disposeBag.self.insert(ObserverService.shared.userLoginStatusDescription)})
    }
    
    private func handleUserLogIn(_ loginStatus: Bool) {
        print("LoginScreenViewModel: Handle user login. Logged in: \(loginStatus)")
        if (loginStatus) {
            userLoginInfo.onNext("User logged in successfully")
            NotificationCenter.default.post(name: .logUserIn, object: nil)
        } else {
            User.profile.clearUserDefaults()
        }
    }
    
    private func handleUserLoginError(_ error: Error) {
        print("LoginScreenViewModel: Handle user login error")
        userLoginInfo.onNext("Error with user login")
    }
    
    func login(_ username: String, _ password: String) {
        let parameters = ["username":username, "password":password]
        User.profile.setUserDefaults(username)
        print("Logging in with parameters: \(parameters)")
        NetworkManager.shared.sendRequest(parameters, .userLogin)
    }
}

extension Notification.Name {
    static let logUserIn = Notification.Name("logUserIn")
}
