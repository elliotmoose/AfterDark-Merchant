import Foundation
class Settings
{
    //test
    static let ignoreUserDefaults = false
    static let bypassLoginPage = false
    static let modelBarActive = false
    static let dummyAppOn = false
    static let singleton = Settings()
    
    static let googleMapsKey = "AIzaSyANTsheZ7ClHH98Js5p1QA-7QIqw_KPrLQ"
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
