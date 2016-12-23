import Foundation
class Settings
{
    //test
    static let ignoreUserDefaults = false
    static let bypassLoginPage = false
    static let modelBarActive = false
    static let dummyAppOn = false
    static let singleton = Settings()
    
    
    init()
    {
        self.LoadSettings()
    }

    func SaveSettings()
    {
        UserDefaults.standard.setValue(Account.singleton.user_name, forKey: "username")
    }

    func LoadSettings()
    {
        
    }


}
