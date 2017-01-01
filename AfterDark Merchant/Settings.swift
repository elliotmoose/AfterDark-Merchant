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
    }

    func LoadSettings()
    {
        
    }


}
