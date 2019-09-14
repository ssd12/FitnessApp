import Foundation

class User {
    
    static let profile = User()
    
    init() {
        
    }
    
    func setUserDefaults(_ username: String) {
        let defaults = UserDefaults.standard
        defaults.set(username, forKey: "username")
        defaults.set(true, forKey: "isUserLoggedIn")
    }
    
    func clearUserDefaults() {
        let defaults = UserDefaults.standard
        defaults.set("", forKey: "username")
        defaults.set(false, forKey: "isUserLoggedIn")
    }
}
