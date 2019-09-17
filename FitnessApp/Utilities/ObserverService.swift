import Foundation
import RxSwift

class ObserverService {
    
    static let shared = ObserverService()
    var disposeBag = DisposeBag()
    
    let isUserLoggedIn: BehaviorSubject<Bool> = BehaviorSubject(value: false)
    let userLoginStatusDescription: BehaviorSubject<String> = BehaviorSubject(value: "User not logged in.")
    let isUserLoggedOut: BehaviorSubject<Bool> = BehaviorSubject(value: false)
    let registrationSuccessful: BehaviorSubject<Bool> = BehaviorSubject(value: false)
    let registrationStatusDescription: BehaviorSubject<String> = BehaviorSubject(value: "")
    let userAccountDeletedSuccesful: BehaviorSubject<Bool> = BehaviorSubject(value: false)
    let userActiviyAddedSuccessful: BehaviorSubject<Bool> = BehaviorSubject(value: false)
    
    init() {
        
    }
    
    func emitObservable(_ response: Utilities.ResponseType, _ info: String) {
        print("Response Type: \(response)")
        switch response {
        case .loginSuccessful:
            print("User login sucessful")
            userLoginStatusDescription.onNext(info)
            isUserLoggedIn.onNext(true)
        case .loginError:
            isUserLoggedIn.onNext(false)
            userLoginStatusDescription.onNext(info)
            print("User login error")
        case .logoutSuccessful:
            print("User Logout Successful")
            isUserLoggedOut.onNext(true)
            userLoginStatusDescription.onNext(info)
        case .registrationSuccessful:
            print("Registration Successful")
            registrationSuccessful.onNext(true)
            registrationStatusDescription.onNext(info)
        case .registrationError:
            registrationSuccessful.onNext(false)
            registrationStatusDescription.onNext(info)
        case .activityAdded:
            print("Activity Added")
            userActiviyAddedSuccessful.onNext(true)
        case .userDeleted:
            print("User account deleted")
            userAccountDeletedSuccesful.onNext(false)
            userLoginStatusDescription.onNext(info)
        case .userActivitiesFetched:
            print("Fetched all user activites")
            print(info)
        case .error:
            print("Error")
        }
    }
    
}
